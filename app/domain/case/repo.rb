class Case
  class Repo < ::Repo
    # -- lifetime --
    def self.get
      Repo.new
    end

    def initialize(
      domain_events: Services.domain_events,
      supplier_repo: ::Supplier::Repo.get,
      enroller_repo: ::Enroller::Repo.get
    )
      @domain_events = domain_events
      @supplier_repo = supplier_repo
      @enroller_repo = enroller_repo
    end

    # -- queries --
    # -- queries/one
    def find(case_id)
      case_rec = Case::Record
        .find(case_id)

      entity_from(case_rec)
    end

    def find_by_phone_number(phone_number)
      case_rec = Case::Record
        .includes(:recipient)
        .references(:recipients)
        .find_by(recipients: { phone_number: phone_number })

      entity_from(case_rec)
    end

    def find_with_document(case_id, document_id)
      document_rec = Document::Record
        .includes(:case)
        .find_by!(
          id: document_id,
          case_id: case_id
        )

      entity_from(document_rec.case, [document_rec])
    end

    def find_with_documents(case_id)
      case_rec = Case::Record
        .find(case_id)

      # TODO: fix n+1 on attachments and blobs
      document_recs = Document::Record
        .where(case_id: case_id)

      entity_from(case_rec, document_recs)
    end

    def find_opened_with_documents(case_id)
      case_rec = Case::Record
        .where(status: [:opened, :pending])
        .find(case_id)

      # TODO: fix n+1 on attachments and blobs
      document_recs = Document::Record
        .where(case_id: case_id)

      entity_from(case_rec, document_recs)
    end

    def find_by_enroller_with_documents(case_id, enroller_id)
      case_rec = Case::Record
        .where(
          enroller_id: enroller_id,
          status: [:submitted, :approved, :denied]
        )
        .find(case_id)

      # TODO: fix n+1 on attachments and blobs
      document_recs = Document::Record
        .where(case_id: case_id)

      entity_from(case_rec, document_recs)
    end

    # -- queries/many
    def find_all_incomplete
      case_recs = Case::Record
        .where(completed_at: nil)
        .order(updated_at: :desc)
        .includes(:recipient)

      # pre-load associated aggregates
      @supplier_repo.find_many(case_recs.map(&:supplier_id))
      @enroller_repo.find_many(case_recs.map(&:enroller_id))

      entities_from(case_recs)
    end

    def find_all_for_dhs
      case_recs = Case::Record
        .where(status: [:opened, :pending])
        .order(updated_at: :desc)
        .includes(:recipient)

      entities_from(case_recs)
    end

    def find_all_for_enroller(enroller_id)
      case_recs = Case::Record
        .where(
          enroller_id: enroller_id,
          status: [:submitted, :approved, :denied]
        )
        .order(updated_at: :desc)
        .includes(:recipient)

      # pre-load associated aggregates
      @enroller_repo.find(enroller_id)
      @supplier_repo.find_many(case_recs.map(&:supplier_id))

      entities_from(case_recs)
    end

    # -- commands --
    def save_account_and_recipient_profile(kase)
      # start a new case record
      case_rec = Case::Record.new

      # update the case record
      c = kase
      case_rec.assign_attributes(
        enroller_id: c.enroller_id,
        supplier_id: c.supplier_id,
      )

      assign_account(kase, case_rec)

      # find or update a recipient record with a matching phone number
      p = kase.recipient.profile.phone
      recipient_rec = Recipient::Record.find_or_initialize_by(
        phone_number: p.number
      )

      assign_recipient_profile(kase, recipient_rec)

      # save the records
      case_rec.recipient = recipient_rec
      case_rec.save!

      # send creation events back to entities
      kase.did_save(case_rec)
      kase.recipient.did_save(recipient_rec)

      # consume all entity events
      @domain_events.consume(kase.events)
    end

    def save_status_and_dhs_account(kase)
      case_rec = kase.record
      recipient_rec = kase.recipient.record

      if case_rec.nil? || recipient_rec.nil?
        raise "case and recipient must be fetched from the db!"
      end

      # update records
      assign_status(kase, case_rec)
      assign_dhs_account(kase, recipient_rec)

      # save records
      transaction do
        case_rec.save!
        recipient_rec.save!
      end

      # consume all entity events
      @domain_events.consume(kase.events)
    end

    def save_all_fields_and_new_documents(kase)
      case_rec = kase.record
      recipient_rec = kase.recipient.record

      if case_rec.nil? || recipient_rec.nil?
        raise "case and recipient must be fetched from the db!"
      end

      # update records
      assign_status(kase, case_rec)
      assign_account(kase, case_rec)
      assign_recipient_profile(kase, recipient_rec)
      assign_dhs_account(kase, recipient_rec)

      # save records
      transaction do
        case_rec.save!
        recipient_rec.save!
        create_documents!(kase.id.val, kase.new_documents)
      end

      # consume all entity events
      @domain_events.consume(kase.events)
    end

    def save_message_changes(kase)
      case_rec = kase.record
      if case_rec.nil?
        raise "case must be fetched from the db!"
      end

      # update records
      c = kase
      case_rec.received_message_at = c.received_message_at

      # save records
      transaction do
        case_rec.save!
        create_documents!(kase.id.val, kase.new_documents)
      end

      # consume all entity events
      @domain_events.consume(kase.events)
    end

    def save_attached_file(kase)
      document = kase.selected_document
      if document.nil?
        raise "no document was selected"
      end

      document_rec = document.record
      if document_rec.nil?
        raise "unsaved document can't be updated with a new file"
      end

      new_file = document.new_file
      if new_file.nil?
        return
      end

      f = new_file
      document_rec.file.attach(
        io: f.data,
        filename: f.name,
        content_type: f.mime_type
      )

      # consume all entity events
      @domain_events.consume(kase.events)
    end

    def save_completed(kase)
      case_rec = kase.record

      # update records
      assign_status(kase, case_rec)

      # save records
      case_rec.save!

      # consume all entity events
      @domain_events.consume(kase.events)
    end

    # -- commands/helpers
    private def assign_status(kase, case_rec)
      c = kase
      case_rec.assign_attributes(
        status: c.status,
        completed_at: c.completed_at
      )
    end

    private def assign_account(kase, case_rec)
      a = kase.account
      case_rec.assign_attributes(
        account_number: a.number,
        account_arrears_cents: a.arrears_cents
      )
    end

    private def assign_recipient_profile(kase, recipient_rec)
      r = kase.recipient

      p = r.profile.phone
      recipient_rec.assign_attributes(
        phone_number: p.number
      )

      n = r.profile.name
      recipient_rec.assign_attributes(
        first_name: n.first,
        last_name: n.last,
      )

      a = r.profile.address
      recipient_rec.assign_attributes(
        street: a.street,
        street2: a.street2,
        city: a.city,
        state: a.state,
        zip: a.zip
      )
    end

    private def assign_dhs_account(kase, recipient_rec)
      r = kase.recipient

      a = r.dhs_account
      recipient_rec.assign_attributes(
        dhs_number: a.number,
      )

      h = a.household
      recipient_rec.assign_attributes(
        household_size: a.household.size,
        household_income_cents: a.household.income_cents
      )
    end

    private def create_documents!(case_id, documents)
      if documents.blank?
        return
      end

      document_recs_attrs = documents.map do |d|
        _attrs = {
          case_id: case_id,
          classification: d.classification,
          source_url: d.source_url
        }
      end

      document_recs = Document::Record.create!(document_recs_attrs)

      # send creation events back to entities
      document_recs.each_with_index do |r, i|
        documents[i].did_save(r)
      end
    end

    # -- commands/helpers
    private def transaction(&block)
      Case::Record.transaction(&block)
    end

    # -- factories --
    def self.map_record(r, document_recs = nil)
      Case.new(
        record: r,
        id: Id.new(r.id),
        status: r.status.to_sym,
        enroller_id: r.enroller_id,
        supplier_id: r.supplier_id,
        account: Case::Account.new(
          number: r.account_number,
          arrears_cents: r.account_arrears_cents,
        ),
        documents: document_recs&.map { |d|
          map_document(d)
        },
        recipient: map_recipient(r.recipient),
        updated_at: r.updated_at,
        completed_at: r.completed_at
      )
    end

    def self.map_document(r)
      Document.new(
        record: r,
        id: Id.new(r.id),
        classification: r.classification.to_sym,
        file: r.file,
        source_url: r.source_url
      )
    end

    def self.map_recipient(r)
      Recipient.new(
        record: r,
        id: r.id,
        profile: Recipient::Profile.new(
          phone: Recipient::Phone.new(
            number: r.phone_number
          ),
          name: Recipient::Name.new(
            first: r.first_name,
            last: r.last_name
          ),
          address: Recipient::Address.new(
            street: r.street,
            street2: r.street2,
            city: r.city,
            state: r.state,
            zip: r.zip
          ),
        ),
        dhs_account: r.dhs_number&.then { |number|
          Recipient::DhsAccount.new(
            number: number,
            household: Recipient::Household.new(
              size: r.household_size,
              income_cents: r.household_income_cents
            )
          )
        }
      )
    end
  end
end
