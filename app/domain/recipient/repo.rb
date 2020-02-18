class Recipient
  class Repo < ::Repo
    # -- lifetime --
    def self.get
      Repo.new
    end

    # -- queries --
    # -- queries/one
    def find(id)
      recipient_rec = Recipient::Record
        .find(id)

      return entity_from(recipient_rec)
    end

    # -- factories --
    def self.map_record(r)
      Recipient.new(
        record: r,
        id: Id.new(r.id),
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
