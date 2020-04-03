class Case
  class Repo < ::Repo
    # -- lifetime --
    def self.get
      Repo.new
    end

    def initialize(
      domain_events: Services.domain_events,
      partner_repo: ::Partner::Repo.get
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
        .join_recipient(references: true)
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

      is_referrer = Case::Record
        .exists?(referrer_id: case_id)

      return entity_from(case_rec, assignments: case_rec.assignments, documents: document_recs, is_referrer: is_referrer)
    end

    def find_for_dhs(case_id)
      case_rec = Case::Record
        .for_governor
        .find(case_id)

      return entity_from(case_rec)
    end

    def find_with_documents_for_dhs(case_id)
      case_rec = Case::Record
        .for_governor
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
        .where(status: [:opened, :pending, :submitted])
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

    def find_all_assigned_by_user(user_id, page:)
      case_query = Case::Record
        .join_recipient
        .incomplete
        .with_assigned_user(user_id.val)
        .by_most_recently_updated

      return paged_entities_from(case_query, page)
    end

    def find_all_queued_for_cohere(partner_id, page:)
      case_query = Case::Record
        .join_recipient
        .incomplete
        .with_no_assignment_for_partner(partner_id)
        .by_most_recently_updated

      return paged_entities_from(case_query, page)
    end

    def find_all_opened_for_cohere(partner_id, page:)
      case_query = Case::Record
        .join_recipient
        .incomplete
        .by_most_recently_updated

      return paged_entities_from(case_query, page, selected_assignment: partner_id)
    end

    def find_all_completed_for_cohere(partner_id, page:)
      case_query = Case::Record
        .join_recipient
        .where.not(completed_at: nil)
        .order(completed_at: :desc)

      return paged_entities_from(case_query, page, selected_assignment: partner_id)
    end

    def find_all_queued_for_dhs(governor_id, page:)
      case_query = Case::Record
        .join_recipient
        .for_governor
        .with_no_assignment_for_partner(governor_id)
        .by_most_recently_updated

      return paged_entities_from(case_query, page, partners: false)
    end

    def find_all_opened_for_dhs(governor_id, page:)
      case_query = Case::Record
        .join_recipient
        .for_governor
        .by_most_recently_updated

      return paged_entities_from(case_query, page, selected_assignment: governor_id, partners: false)
    end

    def find_all_opened_for_supplier(supplier_id, page:)
      case_query = Case::Record
        .join_recipient
        .where(supplier_id: supplier_id)
        .by_most_recently_updated

      return paged_entities_from(case_query, page, selected_assignment: supplier_id, partners: false)
    end

    def find_all_queued_for_enroller(enroller_id, page:)
      case_query = Case::Record
        .join_recipient
        .incomplete
        .for_enroller(enroller_id)
        .with_no_assignment_for_partner(enroller_id)
        .by_most_recently_updated

      return paged_entities_from(case_query, page)
    end

    def find_all_submitted_for_enroller(enroller_id, page:)
      case_query = Case::Record
        .join_recipient
        .for_enroller(enroller_id)
        .by_most_recently_updated

      return paged_entities_from(case_query, page, selected_assignment: enroller_id)
    end

    # -- queries/helpers
    private def paged_entities_from(case_query, page, selected_assignment: nil, partners: true)
      # paginate the results
      case_page = Pagy.new(count: case_query.count(:all), page: page)
      case_recs = case_query.offset(case_page.offset).limit(case_page.items)

      # pre-load other aggregates, if any
      if partners
        partner_ids = case_recs
          .map(&:enroller_id)
          .concat(case_recs.map(&:supplier_id))
          .uniq

        @partner_repo.find_all_by_ids(partner_ids)
      end

      # pre-load assignments records, if any
      assignment_recs_by_id = if selected_assignment != nil
        assignment_query = Assignment::Record
          .join_user
          .by_partner(selected_assignment)
          .where(case: case_recs)
          .group_by(&:case_id)
      end

      # transform the results
      cases = case_recs.map do |r|
        entity = entity_from(r,
          assignments: assignment_recs_by_id&.dig(r.id)
        )

        if selected_assignment != nil
          entity.select_assignment(selected_assignment)
        end

        entity
      end

      return case_page, cases
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

      assign_recipient_profile(kase, recipient_rec)

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

    def save_dhs_contribution(kase)
      case_rec = kase.record
      recipient_rec = kase.recipient.record

      if case_rec.nil? || recipient_rec.nil?
        raise "case and recipient must be fetched from the db!"
      end

      # update records
      assign_status(kase, case_rec)
      assign_activity(kase, case_rec)
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
      assign_activity(kase, case_rec)
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
        program: referred.program,
        recipient_id: referred.recipient.id.val,
        referrer_id: referrer.id.val
      )

      assign_status(referred, referred_rec)
      assign_activity(referred, referred_rec)
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

    def save_destroyed(kase)
      kase.record.destroy!
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

    private def assign_activity(kase, case_rec)
      c = kase
      case_rec.assign_attributes(
        has_new_activity: c.has_new_activity,
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
        case_id: c.id.val,
        user_id: assignment.user_id.val,
        partner_id: assignment.partner_id,
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

    private def transaction(&block)
      Case::Record.transaction(&block)
    end

    # -- factories --
    def self.map_record(r, assignments: nil, documents: nil, is_referrer: false)
      Case.new(
        record: r,
        id: Id.new(r.id),
        program: r.program.to_sym,
        status: r.status.to_sym,
        recipient: map_recipient(r.recipient),
        enroller_id: r.enroller_id,
        supplier_id: r.supplier_id,
        supplier_account: map_supplier_account(r),
        documents: documents&.map { |r| map_document(r) },
        assignments: assignments&.map { |r| map_assignment(r) },
        is_referrer: is_referrer,
        is_referred: r.referrer_id.present?,
        has_new_activity: r.has_new_activity,
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
        dhs_account: ::Recipient::Repo.map_dhs_account(r),
      )
    end

    def self.map_supplier_account(r)
      return Account.new(
        number: r.supplier_account_number,
        arrears_cents: r.supplier_account_arrears_cents,
        has_active_service: r.supplier_account_active_service
      )
    end

    def self.map_assignment(r)
      return Assignment.new(
        user_id: r.user.id,
        user_email: r.user.email,
        partner_id: r.partner_id,
        partner_membership: r.partner.membership.to_sym,
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

  class Record
    # -- scopes --
    def self.join_recipient(references: false)
      scope = includes(:recipient)

      if references
        scope = scope.references(:recipients)
      end

      return scope
    end

    def self.join_assignments
      return includes(:assignments)
    end

    def self.incomplete
      return where(completed_at: nil)
    end

    def self.for_governor
      return where(
        program: Program::Name::Meap,
        status: [Status::Opened, Status::Pending]
      )
    end

    def self.for_enroller(enroller_id)
      return where(
        enroller_id: enroller_id,
        status: [Status::Submitted, Status::Approved, Status::Denied],
      )
    end

    def self.with_assigned_user(user_id)
      scope = self
        .includes(:assignments)
        .references(:case_assignments)
        .where(case_assignments: { user_id: user_id })

      return scope
    end

    def self.with_no_assignment_for_partner(partner_id)
      query = <<~SQL
        SELECT 1
        FROM case_assignments AS ca
        WHERE ca.case_id = cases.id AND ca.partner_id = ?
      SQL

      return where("NOT EXISTS (#{query})", partner_id)
    end

    def self.by_most_recently_updated
      return order(updated_at: :desc)
    end
  end

  class Assignment::Record
    def self.join_user
      return includes(:user)
    end

    def self.by_partner(partner_id)
      return where(partner_id: partner_id)
    end
  end
end
