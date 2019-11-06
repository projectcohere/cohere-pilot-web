class Case
  class Repo < ::Repo
    # -- lifetime --
    def self.get
      Repo.new
    end

    # -- queries --
    # -- queries/one
    def find_one(id)
      record = Case::Record
        .find(id)

      entity_from(record)
    end

    def find_one_by_phone_number(phone_number)
      record = Case::Record
        .includes(:recipient)
        .references(:recipients)
        .find_by(recipients: { phone_number: phone_number })

      entity_from(record)
    end

    def find_one_for_enroller(id, enroller_id)
      record = Case::Record
        .where(
          enroller_id: enroller_id,
          status: [:submitted, :approved, :rejected]
        )
        .find(id)

      entity_from(record)
    end

    def find_one_opened(id)
      record = Case::Record
        .where(status: [:opened, :pending])
        .find(id)

      entity_from(record)
    end

    # -- queries/many
    def find_incomplete
      records = Case::Record
        .where(completed_at: nil)
        .order(updated_at: :desc)
        .includes(:supplier, :enroller, :documents, recipient: [:household, { account: :supplier }])

      entities_from(records)
    end

    def find_for_enroller(enroller_id)
      records = Case::Record
        .where(
          enroller_id: enroller_id,
          status: [:submitted, :approved, :rejected]
        )
        .order(updated_at: :desc)
        .includes(:supplier, :enroller, :documents, recipient: [:household, { account: :supplier }])

      entities_from(records)
    end

    def find_opened
      records = Case::Record
        .where(status: [:opened, :pending])
        .order(updated_at: :desc)
        .includes(:supplier, :enroller, :documents, recipient: [:household, { account: :supplier }])

      entities_from(records)
    end

    # -- commands --
    def save_opened(kase)
      # start a new case record
      case_record = Case::Record.new

      # update the case record
      case_record.assign_attributes(
        enroller_id: kase.enroller_id,
        supplier_id: kase.supplier_id,
      )

      assign_account(kase, case_record)

      # find or update a recipient with a matching phone number
      recipient_record = Recipient::Record.find_or_initialize_by(
        phone_number: kase.recipient.profile.phone.number
      )

      assign_recipient_profile(kase, recipient_record)

      # save the records
      case_record.transaction do
        case_record.recipient = recipient_record
        case_record.save!
      end

      # send creation events back to the domain objects
      kase.did_save(case_record)
      kase.recipient.did_save(recipient_record)
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
    end

    def save_all_fields(kase)
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
    end

    # -- commands/helpers
    private def assign_status(kase, case_record)
      c = kase
      case_record.assign_attributes(
        status: c.status
      )
    end

    private def assign_account(kase, case_record)
      a = kase.account
      case_record.assign_attributes(
        account_number: a.number,
        account_arrears: a.arrears
      )
    end

    private def assign_recipient_profile(kase, recipient_record)
      r = kase.recipient

      p = r.profile.phone
      recipient_record.assign_attributes(
        phone_number: p.number
      )

      n = r.profile.name
      recipient_record.assign_attributes(
        first_name: n.first,
        last_name: n.last,
      )

      a = r.profile.address
      recipient_record.assign_attributes(
        street: a.street,
        street2: a.street2,
        city: a.city,
        state: a.state,
        zip: a.zip
      )
    end

    private def assign_dhs_account(kase, recipient_record)
      r = kase.recipient

      a = r.dhs_account
      recipient_record.assign_attributes(
        dhs_number: a.number,
      )

      h = a.household
      recipient_record.assign_attributes(
        dhs_household_size: a.household.size,
        dhs_household_income: a.household.income
      )
    end

    # -- factories --
    def self.map_record(r)
      Case.new(
        record: r,
        id: r.id,
        status: r.status.to_sym,
        enroller_id: r.enroller_id,
        supplier_id: r.supplier_id,
        recipient: map_recipient(r.recipient),
        account: Case::Account.new(
          number: r.account_number,
          arrears: r.account_arrears,
        ),
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
            size: r.dhs_household_size,
            income: r.dhs_household_income
          )
        )
      )
    end
  end
end
