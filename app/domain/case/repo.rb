class Case
  class Repo < ::Repo
    # -- lifetime --
    def self.get
      Repo.new
    end

    def initialize(
      event_queue: EventQueue.get,
      supplier_repo: ::Supplier::Repo.get,
      enroller_repo: ::Enroller::Repo.get
    )
      @event_queue = event_queue
      @supplier_repo = supplier_repo
      @enroller_repo = enroller_repo
    end

    # -- queries --
    # -- queries/one
    def find(id)
      record = Case::Record
        .find(id)

      entity_from(record)
    end

    def find_by_phone_number(phone_number)
      record = Case::Record
        .includes(:recipient)
        .references(:recipients)
        .find_by(recipients: { phone_number: phone_number })

      entity_from(record)
    end

    def find_for_enroller(id, enroller_id)
      record = Case::Record
        .where(
          enroller_id: enroller_id,
          status: [:submitted, :approved, :rejected]
        )
        .find(id)

      entity_from(record)
    end

    def find_opened(id)
      record = Case::Record
        .where(status: [:opened, :pending])
        .find(id)

      entity_from(record)
    end

    # -- queries/many
    def find_all_incomplete
      records = Case::Record
        .where(completed_at: nil)
        .order(updated_at: :desc)
        .includes(:recipient)

      # pre-fetch associations
      @supplier_repo.find_many(records.map(&:supplier_id))
      @enroller_repo.find_many(records.map(&:enroller_id))

      entities_from(records)
    end

    def find_all_for_enroller(enroller_id)
      records = Case::Record
        .where(
          enroller_id: enroller_id,
          status: [:submitted, :approved, :rejected]
        )
        .order(updated_at: :desc)
        .includes(:recipient)

      # pre-fetch associations
      @enroller_repo.find(enroller_id)
      @supplier_repo.find_many(records.map(&:supplier_id))

      entities_from(records)
    end

    def find_all_opened
      records = Case::Record
        .where(status: [:opened, :pending])
        .order(updated_at: :desc)
        .includes(:recipient)

      entities_from(records)
    end

    # -- commands --
    def save_opened(kase)
      # start a new case record
      case_rec = Case::Record.new

      # update the case record
      case_rec.assign_attributes(
        enroller_id: kase.enroller_id,
        supplier_id: kase.supplier_id,
      )

      assign_account(kase, case_rec)

      # find or update a recipient with a matching phone number
      recipient_rec = Recipient::Record.find_or_initialize_by(
        phone_number: kase.recipient.profile.phone.number
      )

      assign_recipient_profile(kase, recipient_rec)

      # save the records
      case_rec.transaction do
        case_rec.recipient = recipient_rec
        case_rec.save!
      end

      # send creation events back to entities
      kase.did_save(case_rec)
      kase.recipient.did_save(recipient_rec)

      # consume all entity events
      @event_queue.consume(kase.events)
    end

    def save_dhs_account(kase)
      if kase.record.nil? || kase.recipient.record.nil?
        raise "case and recipient must be fetched from the db!"
      end

      # update records
      assign_status(kase, kase.record)
      assign_dhs_account(kase, kase.recipient.record)

      # save records
      kase.record.transaction do
        kase.record.save!
        kase.recipient.record.save!
      end

      # consume all entity events
      @event_queue.consume(kase.events)
    end

    def save(kase)
      if kase.record.nil? || kase.recipient.record.nil?
        raise "case and recipient must be fetched from the db!"
      end

      # update records
      assign_status(kase, kase.record)
      assign_account(kase, kase.record)
      assign_recipient_profile(kase, kase.recipient.record)
      assign_dhs_account(kase, kase.recipient.record)

      # save records
      kase.record.transaction do
        kase.record.save!
        kase.recipient.record.save!
      end

      # consume all entity events
      @event_queue.consume(kase.events)
    end

    # -- commands/helpers
    private def assign_status(kase, case_rec)
      c = kase
      case_rec.assign_attributes(
        status: c.status
      )
    end

    private def assign_account(kase, case_rec)
      a = kase.account
      case_rec.assign_attributes(
        account_number: a.number,
        account_arrears: a.arrears
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
        household_income: a.household.income
      )
    end

    # -- factories --
    def self.map_record(r)
      Case.new(
        record: r,
        id: Id.new(r.id),
        status: r.status.to_sym,
        enroller_id: r.enroller_id,
        supplier_id: r.supplier_id,
        account: Case::Account.new(
          number: r.account_number,
          arrears: r.account_arrears,
        ),
        recipient: map_recipient(r.recipient),
        updated_at: r.updated_at,
        completed_at: r.completed_at
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
        dhs_account: Recipient::DhsAccount.new(
          number: r.dhs_number,
          household: Recipient::Household.new(
            size: r.household_size,
            income: r.household_income
          )
        )
      )
    end
  end
end
