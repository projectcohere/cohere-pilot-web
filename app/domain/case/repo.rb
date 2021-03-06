class Case
  class Repo < ::Repo
    include Service
    include Case::Policy::Context

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
      case_rec = make_query
        .find(case_id)

      return entity_from(case_rec)
    end

    def find_by_phone_number(phone_number)
      case_rec = make_query
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
      case_rec = make_query
        .join_assignments
        .find(case_id)

      document_recs = Document::Record
        .with_attached_file
        .where(case_id: case_id)

      return entity_from(case_rec, assignments: case_rec.assignments, documents: document_recs)
    end

    def find_by_chat_recipient(recipient_id)
      case_rec = Case::Record
        .active
        .order(created_at: :desc)
        .find_by(recipient_id: recipient_id)

      return entity_from(case_rec)
    end

    # -- queries/many
    def find_all_by_ids(case_ids)
      case_recs = Case::Record
        .join_recipient
        .where(id: case_ids)

      return case_recs.map { |r| entity_from(r) }
    end

    # -- queries/helpers
    private def make_query
      q = Case::Record

      # filter by role
      q = case user_role
      when Role::Source
        q.for_source(user_partner_id)
      when Role::Governor
        q.for_governor(user_partner_id)
      when Role::Enroller
        q.for_enroller(user_partner_id)
      else
        q
      end

      return q
    end

    # -- commands --
    def save_opened(kase)
      # intiailize record
      case_rec = Case::Record.new
      assign_program(kase, case_rec)
      assign_partners(kase, case_rec)
      assign_status(kase, case_rec)
      assign_activity(kase, case_rec)
      assign_program_fields(kase, case_rec)

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
      assert(kase.record != nil, "case must be persisted.")
      assert(kase.recipient.record != nil, "recipient must be persisted.")

      # update records
      case_rec = kase.record
      assign_status(kase, case_rec)
      assign_activity(kase, case_rec)

      recipient_rec = kase.recipient.record
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
      assert(kase.record != nil, "case must be persisted.")
      assert(kase.recipient.record != nil, "recipient must be persisted.")

      # update records
      case_rec = kase.record
      assign_status(kase, case_rec)
      assign_benefit(kase, case_rec)
      assign_activity(kase, case_rec)
      assign_program_fields(kase, case_rec)

      recipient_rec = kase.recipient.record
      assign_profile(kase, recipient_rec)
      assign_household(kase, recipient_rec)

      # save records
      transaction do
        case_rec.save!
        recipient_rec.save!
        create_documents!(kase.id.val, kase.new_documents)
        destroy_removed_assignment!(kase)
      end

      # consume all entity events
      @domain_events.consume(kase.events)
    end

    def save_converted(kase)
      assert(kase.record != nil, "case must be persisted.")

      # update records
      case_rec = kase.record
      assign_program(kase, case_rec)

      # save records
      case_rec.save!

      # consume all entity events
      @domain_events.consume(kase.events)
    end

    def save_new_assignment(kase)
      assert(kase.record != nil, "case must be persisted.")

      # initialize record
      assignment_rec = Assignment::Record.new
      assign_new_assignment(kase, assignment_rec)

      # save record
      assignment_rec.save!

      # consume all entity events
      @domain_events.consume(kase.events)
    end

    def save_removed_assignment(kase)
      assert(kase.record != nil, "case must be persisted.")

      # destroy record
      destroy_removed_assignment!(kase)

      # consume all entity events
      @domain_events.consume(kase.events)
    end

    def save_new_note(kase)
      assert(kase.record != nil, "case must be persisted.")
      assert(kase.selected_note != nil, "case has no new note")

      # create records
      create_new_note!(kase)

      # consume all entity events
      @domain_events.consume(kase.events)
    end

    def save_new_message(kase)
      assert(kase.record != nil, "case must be persisted.")

      case_rec = kase.record

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
      assert(document != nil, "case has no selected document")

      document_rec = document.record
      assert(document_rec != nil, "document must be persisted")

      new_file = document.new_file
      if new_file == nil
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
      assert(kase.record != nil, "case must be persisted")

      # update case record
      case_rec = kase.record
      assign_status(kase, case_rec)
      assign_benefit(kase, case_rec)
      assign_activity(kase, case_rec)

      # save records
      transaction do
        case_rec.save!
        destroy_removed_assignment!(kase)
      end

      # consume all entity events
      @domain_events.consume(kase.events)
    end

    def save_returned(kase)
      assert(kase.record != nil, "case must be persisted")

      # update the record
      case_rec = kase.record
      assign_status(kase, case_rec)
      assign_activity(kase, case_rec)

      # save the record
      transaction do
        case_rec.save!
        destroy_removed_assignment!(kase)
      end

      # consume all entity events
      @domain_events.consume(kase.events)
    end

    def save_archived(kase)
      assert(kase.record != nil, "case must be persisted")

      # update the record
      case_rec = kase.record
      assign_status(kase, case_rec)

      # save the record
      case_rec.save!

      # consume all entity events
      @domain_events.consume(kase.events)
    end

    def save_deleted(kase)
      assert(kase.record != nil, "case must be persisted")

      # update the record
      case_rec = kase.record
      assign_status(kase, case_rec)

      # save the record
      case_rec.save!

      # consume all entity events
      @domain_events.consume(kase.events)
    end

    def save_referral(referral)
      assert(referral.referrer.record != nil, "referrer must be persisted")
      assert(referral.referred.recipient.record != nil, "recipient must be persisted")

      # update the referrer record
      referrer = referral.referrer
      referrer_rec = referrer.record
      assign_status(referrer, referrer_rec)

      # start a new record for the referred
      referred = referral.referred
      referred_rec = Case::Record.new

      # update the referred record
      referred_rec.assign_attributes(
        recipient_id: referred.recipient.id.val,
      )

      assign_program(referred, referred_rec)
      assign_partners(referred, referred_rec)
      assign_status(referred, referred_rec)
      assign_activity(referred, referred_rec)
      assign_program_fields(referred, referred_rec)

      # update the recipient record
      recipient_rec = referred.recipient.record
      assign_profile(referred, recipient_rec)
      assign_household(referred, recipient_rec)

      # build the initial assignment
      assignment_rec = Case::Assignment::Record.new
      assign_new_assignment(referred, assignment_rec)

      # save the records
      transaction do
        referrer_rec.save!
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

    # -- commands/helpers
    private def assign_program(kase, case_rec)
      rec, c = case_rec, kase
      rec.program_id = c.program.id
    end

    private def assign_partners(kase, case_rec)
      rec, c = case_rec, kase
      rec.enroller_id = c.enroller_id
      rec.supplier_id = c.supplier_account&.supplier_id
    end

    private def assign_status(kase, case_rec)
      rec, c = case_rec, kase
      rec.status = c.status.key
      rec.condition = c.condition.key
      rec.completed_at = c.completed_at
    end

    private def assign_benefit(kase, case_rec)
      rec, c = case_rec, kase
      rec.benefit_amount_cents = c.benefit&.cents
    end

    private def assign_activity(kase, case_rec)
      rec, c = case_rec, kase
      rec.new_activity = c.new_activity
      rec.received_message_at = c.received_message_at
    end

    private def assign_new_assignment(kase, assignment_rec)
      assignment = kase.new_assignment
      assert(assignment != nil, "case has no new assignment")

      rec, c, a = assignment_rec, kase, assignment
      rec.role = a.role.index
      rec.case_id = c.id.val
      rec.user_id = a.user_id.val
      rec.partner_id = a.partner_id
    end

    private def assign_program_fields(kase, case_rec)
      rec, c = case_rec, kase
      rec.dietary_restrictions = c.food&.dietary_restrictions

      a = c.supplier_account
      rec.supplier_account_number = a&.number
      rec.supplier_account_arrears_cents = a&.arrears&.cents
      rec.supplier_account_active_service = a == nil ? true : a.active_service?
    end

    private def assign_profile(kase, recipient_rec)
      rec, r = recipient_rec, kase.recipient

      p = r.profile.phone
      rec.phone_number = p.number

      n = r.profile.name
      rec.first_name = n.first
      rec.last_name = n.last

      a = r.profile.address
      rec.street = a.street
      rec.street2 = a.street2
      rec.city = a.city
      rec.state = a.state
      rec.zip = a.zip
    end

    private def assign_household(kase, recipient_rec)
      rec, h = recipient_rec, kase.recipient.household

      # TODO: need to think through how best to handle partial assignment
      # destroy data if it overwites values with nil (maybe only use assign
      # helpers than expect values or intentional nils, maybe introduce an
      # `omitted` value that is filtered from assignment)
      rec.dhs_number = h.dhs_number || rec.dhs_number
      rec.household_proof_of_income = h.proof_of_income&.key || rec.household_proof_of_income
      rec.household_size = h.size || rec.household_size
      rec.household_income_cents = h.income&.cents || rec.household_income_cents
      rec.household_ownership = h.ownership&.key || rec.household_ownership
    end

    private def create_documents!(case_id, documents)
      if documents.blank?
        return
      end

      # create records
      document_recs = Document::Record.create!(documents.map { |d|
        next {
          classification: d.classification,
          source_url: d.source_url,
          file: d.new_file || d.file&.attachment&.blob,
          case_id: case_id,
        }
      })

      # send creation events back to entities
      document_recs.each_with_index do |r, i|
        documents[i].did_save(r)
      end
    end

    private def create_new_note!(kase)
      note = kase.selected_note
      if note == nil
        return
      end

      # create record
      c, n = kase, note
      Case::Note::Record.create!(
        body: n.body,
        case_id: c.id.val,
        user_id: n.user_id.val,
      )
    end

    private def destroy_removed_assignment!(kase)
      assignment = kase.selected_assignment
      if assignment&.removed? != true
        return
      end

      assignment_rec = kase.record.assignments.find do |a|
        a.user_id == assignment.user_id
      end

      assignment_rec&.destroy!
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
        food: map_food(r),
        benefit: map_benefit(r),
        assignments: assignments&.map { |r| map_assignment(r) },
        documents: documents&.map { |r| map_document(r) },
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

    def self.map_food(r)
      return Food.new(
        dietary_restrictions: r.dietary_restrictions,
      )
    end

    def self.map_benefit(r)
      return Money.cents(r.benefit_amount_cents)
    end

    def self.map_assignment(r)
      return Assignment.new(
        role: Role.from_key(r.role),
        user_id: r.user.id,
        user_email: r.user.email,
        partner_id: r.partner_id,
      )
    end

    def self.map_note(r)
      return Note.new(
        id: Id.new(r.id),
        body: r.body,
        user_id: r.user_id,
        user_email: r.user.email,
        created_at: r.created_at,
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
