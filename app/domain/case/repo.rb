class Case
  class Repo < ::Repo
    include Service

    # -- lifetime --
    def initialize(
      domain_events: ::Events::DispatchAll.get.events,
      partner_repo: Partner::Repo.get
    )
      @domain_events = domain_events
      @partner_repo = partner_repo
    end

    # -- queries --
    # -- queries/one
    def find(case_id)
      case_rec = Case::Record
        .find(case_id)

      return entity_from(case_rec)
    end

    def find_by_phone_number(phone_number)
      case_rec = Case::Record
        .join_recipient
        .find_by(recipients: { phone_number: phone_number })

      return entity_from(case_rec)
    end

    def find_with_document(case_id, document_id)
      document_rec = Document::Record
        .includes(:case)
        .find_by!(
          id: document_id,
          case_id: case_id
        )

      return entity_from(document_rec.case, documents: [document_rec]).tap do |c|
        c.select_document(0)
      end
    end

    def find_with_assignment(case_id, partner_id)
      assignment_rec = Assignment::Record
        .includes(:case)
        .find_by!(
          case_id: case_id,
          partner_id: partner_id,
        )

      return entity_from(assignment_rec.case, assignments: [assignment_rec]).tap do |c|
        c.select_assignment(partner_id.to_i)
      end
    end

    def find_with_associations(case_id)
      case_rec = Case::Record
        .join_assignments
        .find(case_id)

      document_recs = Document::Record
        .with_attached_file
        .where(case_id: case_id)

      return entity_from(case_rec, assignments: case_rec.assignments, documents: document_recs)
    end

    def find_for_governor(case_id, partner_id)
      case_rec = Case::Record
        .for_governor(partner_id)
        .find(case_id)

      return entity_from(case_rec)
    end

    def find_with_documents_for_governor(case_id, partner_id)
      case_rec = Case::Record
        .for_governor(partner_id)
        .find(case_id)

      document_recs = Document::Record
        .with_attached_file
        .where(case_id: case_id)

      return entity_from(case_rec, documents: document_recs)
    end

    def find_for_enroller(case_id, enroller_id)
      case_rec = Case::Record
        .for_enroller(enroller_id)
        .find(case_id)

      return entity_from(case_rec)
    end

    def find_with_documents_for_enroller(case_id, enroller_id)
      case_rec = Case::Record
        .for_enroller(enroller_id)
        .find(case_id)

      document_recs = Document::Record
        .with_attached_file
        .where(case_id: case_id)

      return entity_from(case_rec, documents: document_recs)
    end

    def find_active_by_recipient(recipient_id)
      case_rec = Case::Record
        .where(status: [Status::Opened.key, Status::Pending.key, Status::Submitted.key])
        .order(updated_at: :desc)
        .find_by!(recipient_id: recipient_id)

      return entity_from(case_rec)
    end

    # -- queries/many
    def find_all_by_ids(case_ids)
      case_recs = Case::Record
        .join_recipient
        .where(id: case_ids)

      return case_recs.map { |r| entity_from(r) }
    end

    # -- commands --
    def save_opened(kase)
      # intiailize record
      case_rec = Case::Record.new
      assign_status(kase, case_rec)
      assign_activity(kase, case_rec)
      assign_partners(kase, case_rec)
      assign_supplier_account(kase, case_rec)

      # find or initialize a recipient record by phone number
      recipient_rec = ::Recipient::Record.find_or_initialize_by(
        phone_number: kase.recipient.profile.phone.number
      )

      assign_profile(kase, recipient_rec)
      assign_household(kase, recipient_rec)

      # initialize a new assignment
      assignment_rec = Case::Assignment::Record.new
      assign_new_assignment(kase, assignment_rec)

      # save the records
      transaction do
        case_rec.recipient = recipient_rec
        case_rec.save!
        case_rec.assignments << assignment_rec
      end

      # send creation events back to entities
      kase.did_save(case_rec)
      kase.recipient.did_save(recipient_rec)

      # consume all entity events
      @domain_events.consume(kase.events)
    end

    def save_governor_data(kase)
      case_rec = kase.record
      recipient_rec = kase.recipient.record

      if case_rec.nil? || recipient_rec.nil?
        raise "case and recipient must be fetched from the db!"
      end

      # update records
      assign_status(kase, case_rec)
      assign_activity(kase, case_rec)
      assign_household(kase, recipient_rec)

      # save records
      transaction do
        case_rec.save!
        recipient_rec.save!
      end

      # consume all entity events
      @domain_events.consume(kase.events)
    end

    def save_agent_data(kase)
      case_rec = kase.record
      recipient_rec = kase.recipient.record

      if case_rec.nil? || recipient_rec.nil?
        raise "case and recipient must be fetched from the db!"
      end

      # update records
      assign_status(kase, case_rec)
      assign_activity(kase, case_rec)
      assign_supplier_account(kase, case_rec)
      assign_profile(kase, recipient_rec)
      assign_household(kase, recipient_rec)

      # save records
      transaction do
        case_rec.save!
        recipient_rec.save!
        create_documents!(kase.id.val, kase.new_documents)
      end

      # consume all entity events
      @domain_events.consume(kase.events)
    end

    def save_new_assignment(kase)
      case_rec = kase.record
      if case_rec == nil
        raise "case must be fetched from the db!"
      end

      # initialize record
      assignment_rec = Assignment::Record.new
      assign_new_assignment(kase, assignment_rec)

      # save record
      assignment_rec.save!

      # consume all entity events
      @domain_events.consume(kase.events)
    end

    def save_new_message(kase)
      case_rec = kase.record
      if case_rec.nil?
        raise "case must be fetched from the db!"
      end

      # update records
      assign_activity(kase, case_rec)

      # save records
      transaction do
        case_rec.save!
        create_documents!(kase.id.val, kase.new_documents)
      end

      # consume all entity events
      @domain_events.consume(kase.events)
    end

    def save_selected_document(kase)
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
      assign_activity(kase, case_rec)

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
        recipient_id: referred.recipient.id.val,
        referrer_id: referrer.id.val
      )

      assign_status(referred, referred_rec)
      assign_activity(referred, referred_rec)
      assign_partners(referred, referred_rec)
      assign_supplier_account(referred, referred_rec)
      assign_profile(referred, recipient_rec)
      assign_household(referred, recipient_rec)

      # initialize a new assignment
      assignment_rec = Case::Assignment::Record.new
      assign_new_assignment(referred, assignment_rec)

      # save the records
      transaction do
        referred_rec.save!
        referred_rec.assignments << assignment_rec
        recipient_rec.save!
        create_documents!(referred_rec.id, referred.new_documents)
      end

      # send creation events back to entities
      referred.did_save(referred_rec)

      # consume all entity events
      @domain_events.consume(referrer.events)
      @domain_events.consume(referred.events)
    end

    def save_deleted(kase)
      case_rec = kase.record
      assert(case_rec != nil, "case must be persisted")

      # update the record
      case_rec.assign_attributes(
        condition: kase.condition.key,
      )

      # save the record
      case_rec.save!
    end

    def save_destroyed_assignment(kase)
      case_rec = kase.record
      if case_rec == nil
        raise "case must be fetched from the db!"
      end

      # find record
      assignment_rec = case_rec.assignments.find do |a|
        a.partner_id == kase.selected_assignment.partner_id
      end

      # save record
      assignment_rec.destroy!

      # consume all entity events
      @domain_events.consume(kase.events)
    end

    # -- commands/helpers
    private def assign_partners(kase, case_rec)
      c = kase
      case_rec.assign_attributes(
        program_id: c.program.id,
        enroller_id: c.enroller_id,
      )

      a = c.supplier_account
      case_rec.assign_attributes(
        supplier_id: a&.supplier_id,
      )
    end

    private def assign_status(kase, case_rec)
      c = kase
      case_rec.assign_attributes(
        status: c.status.key,
        condition: c.condition.key,
        completed_at: c.completed_at
      )
    end

    private def assign_activity(kase, case_rec)
      c = kase
      case_rec.assign_attributes(
        new_activity: c.new_activity,
        received_message_at: c.received_message_at,
      )
    end

    private def assign_new_assignment(kase, assignment_rec)
      assignment = kase.new_assignment
      if assignment == nil
        raise "case has no new assignment"
      end

      c = kase
      a = assignment
      assignment_rec.assign_attributes(
        role: a.role.index,
        case_id: c.id.val,
        user_id: a.user_id.val,
        partner_id: a.partner_id,
      )
    end

    private def assign_supplier_account(kase, case_rec)
      a = kase.supplier_account
      case_rec.assign_attributes(
        supplier_account_number: a&.number,
        supplier_account_arrears_cents: a&.arrears&.cents,
        supplier_account_active_service: a.nil? ? true : a.active_service?
      )
    end

    private def assign_profile(kase, recipient_rec)
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

    private def assign_household(kase, rec)
      r = kase.recipient
      h = r.household

      # TODO: need to think through how best to handle partial assignment
      # destroy data if it overwites values with nil (maybe only use assign
      # helpers than expect values or intentional nils, maybe introduce an
      # `omitted` value that is filtered from assignment)
      rec.assign_attributes(
        dhs_number: h.dhs_number || rec.dhs_number,
        household_proof_of_income: h.proof_of_income&.key || rec.household_proof_of_income,
        household_size: h.size || rec.household_size,
        household_income_cents: h.income&.cents || rec.household_income_cents,
        household_ownership: h.ownership&.key || rec.household_ownership,
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

    private def transaction(&block)
      Case::Record.transaction(&block)
    end

    # -- factories --
    def self.map_record(r, assignments: nil, documents: nil)
      return Case.new(
        record: r,
        id: Id.new(r.id),
        status: Status.from_key(r.status),
        condition: Condition.from_key(r.condition),
        program: Program::Repo.map_record(r.program),
        recipient: map_recipient(r.recipient),
        enroller_id: r.enroller_id,
        supplier_account: map_supplier_account(r),
        documents: documents&.map { |r| map_document(r) },
        assignments: assignments&.map { |r| map_assignment(r) },
        referred: r.referrer_id != nil,
        referrer: r.referred != nil,
        new_activity: r.new_activity,
        received_message_at: r.received_message_at,
        created_at: r.created_at,
        updated_at: r.updated_at,
        completed_at: r.completed_at
      )
    end

    def self.map_recipient(r)
      return Recipient.new(
        record: r,
        id: Id.new(r.id),
        profile: ::Recipient::Repo.map_profile(r),
        household: ::Recipient::Repo.map_household(r),
      )
    end

    def self.map_supplier_account(r)
      return Account.new(
        supplier_id: r.supplier_id,
        number: r.supplier_account_number,
        arrears: Money.cents(r.supplier_account_arrears_cents),
        active_service: r.supplier_account_active_service
      )
    end

    def self.map_assignment(r)
      return Assignment.new(
        role: Role.from_key(r.role),
        user_id: r.user.id,
        user_email: r.user.email,
        partner_id: r.partner_id,
      )
    end

    def self.map_document(r)
      return Document.new(
        record: r,
        id: Id.new(r.id),
        classification: r.classification.to_sym,
        file: r.file,
        source_url: r.source_url
      )
    end
  end
end
