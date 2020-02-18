module Recipient
  module Repo
    # -- factories --
    def self.map_profile(r)
      return Profile.new(
        phone: Phone.new(
          number: r.phone_number,
        ),
        name: Name.new(
          first: r.first_name,
          last: r.last_name,
        ),
        address: Address.new(
          street: r.street,
          street2: r.street2,
          city: r.city,
          state: r.state,
          zip: r.zip,
        ),
      )
    end

    def self.map_dhs_account(r)
      if r.dhs_number == nil
        return nil
      end

      return DhsAccount.new(
        number: r.dhs_number,
        household: Household.new(
          size: r.household_size,
          income_cents: r.household_income_cents,
          ownership: r.household_ownership.to_sym,
          is_primary_residence: r.household_primary_residence,
        ),
      )
    end
  end
end
