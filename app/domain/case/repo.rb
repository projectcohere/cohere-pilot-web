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

    def find_with_documents_and_referral(case_id)
      case_rec = Case::Record
        .find(case_id)

      # TODO: fix n+1 on attachments and blobs
      document_recs = Document::Record
        .where(case_id: case_id)

      is_referrer = Case::Record
        .exists?(referrer_id: case_id)

      entity_from(case_rec, document_recs, is_referrer)
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
    def find_all_opened
      case_recs = Case::Record
        .where(completed_at: nil)
        .order(updated_at: :desc)
        .includes(:recipient)

      # pre-load associated aggregates
      @supplier_repo.find_many(case_recs.map(&:supplier_id))
      @enroller_repo.find_many(case_recs.map(&:enroller_id))

      entities_from(case_recs)
    end

    def find_all_completed
      case_recs = Case::Record
        .where.not(completed_at: nil)
        .order(completed_at: :desc)
        .includes(:recipient)

      # pre-load associated aggregates
      @supplier_repo.find_many(case_recs.map(&:supplier_id))
      @enroller_repo.find_many(case_recs.map(&:enroller_id))

      entities_from(case_recs)
    end

    def find_all_for_dhs
      case_recs = Case::Record
        .where(
          program: :meap,
          status: [:opened, :pending]
        )
        .order(created_at: :desc)
        .includes(:recipient)

      entities_from(case_recs)
    end

    def find_all_for_supplier(supplier_id)
      case_recs = Case::Record
        .where(supplier_id: supplier_id)
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
    def save_opened(kase)
      # start a new case record
      case_rec = Case::Record.new

      # update the case record
      assign_partners(kase, case_rec)
      assign_supplier_account(kase, case_rec)

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

    def save_dhs_contribution(kase)
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

    def save_cohere_contribution(kase)
      case_rec = kase.record
      recipient_rec = kase.recipient.record

      if case_rec.nil? || recipient_rec.nil?
        raise "case and recipient must be fetched from the db!"
      end

      # update records
      assign_status(kase, case_rec)
      assign_supplier_account(kase, case_rec)
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

    def save_selected_attachment(kase)
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

    def save_new_attachments(kase)
      create_documents!(kase.id.val, kase.new_documents)

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

    def save_referral(referral)
      # start a new record for the referred
      referred_rec = Case::Record.new
      recipient_rec = referral.referred.recipient.record

      if recipient_rec.nil?
        raise "recipient must be fetched from the db!"
      end

      # update the referred record
      referrer = referral.referrer
      referred = referral.referred
      referred_rec.assign_attributes(
        program: referred.program,
        recipient_id: referred.recipient.id,
        referrer_id: referrer.id.val
      )

      assign_status(referred, referred_rec)
      assign_supplier_account(referred, referred_rec)
      assign_recipient_profile(referred, recipient_rec)
      assign_dhs_account(referred, recipient_rec)
      assign_partners(referred, referred_rec)

      # save the records
      transaction do
        referred_rec.save!
        recipient_rec.save!
        create_documents!(referred_rec.id, referred.new_documents)
      end

      # send creation events back to entities
      referred.did_save(referred_rec)

      # consume all entity events
      @domain_events.consume(referrer.events)
      @domain_events.consume(referred.events)
    end

    # -- commands/helpers
    private def assign_partners(kase, case_rec)
      c = kase
      case_rec.assign_attributes(
        enroller_id: c.enroller_id,
        supplier_id: c.supplier_id
      )
    end

    private def assign_status(kase, case_rec)
      c = kase
      case_rec.assign_attributes(
        status: c.status,
        completed_at: c.completed_at
      )
    end

    private def assign_supplier_account(kase, case_rec)
      a = kase.supplier_account
      case_rec.assign_attributes(
        supplier_account_number: a&.number,
        supplier_account_arrears_cents: a&.arrears_cents,
        supplier_account_active_service: a.nil? ? true : a.has_active_service
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
        household_size: h.size,
        household_income_cents: h.income_cents,
        household_ownership: h.ownership,
        household_primary_residence: h.is_primary_residence
      )
    end

    private def create_documents!(case_id, documents)
      if documents.blank?
        return
      end

      document_attrs = documents.map do |d|
        _attrs = {
          classification: d.classification,
          source_url: d.source_url,
          file: d.new_file || d.file&.attachment&.blob,
          case_id: case_id,
        }
      end

      document_recs = Document::Record.create!(document_attrs)

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
    def self.map_record(r, document_recs = nil, is_referrer = false)
      Case.new(
        record: r,
        id: Id.new(r.id),
        program: r.program.to_sym,
        status: r.status.to_sym,
        recipient: map_recipient(r.recipient),
        enroller_id: r.enroller_id,
        supplier_id: r.supplier_id,
        supplier_account: Case::Account.new(
          number: r.supplier_account_number,
          arrears_cents: r.supplier_account_arrears_cents,
          has_active_service: r.supplier_account_active_service
        ),
        documents: document_recs&.map { |d|
          map_document(d)
        },
        is_referrer: is_referrer,
        is_referred: r.referrer_id.present?,
        received_message_at: r.received_message_at,
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
              income_cents: r.household_income_cents,
              ownership: r.household_ownership.to_sym,
              is_primary_residence: r.household_primary_residence
            )
          )
        }
      )
    end
  end
end
