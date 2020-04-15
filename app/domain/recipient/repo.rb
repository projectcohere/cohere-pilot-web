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

    def self.map_phone(r)
      return Phone.new(
        number: r.phone_number
      )
    end

    def self.map_name(r)
      return Name.new(
        first: r.first_name,
        last: r.last_name,
      )
    end

    def self.map_address(r)
      return Address.new(
        street: r.street,
        street2: r.street2,
        city: r.city,
        state: r.state,
        zip: r.zip,
      )
    end

    def self.map_household(r)
      if r.dhs_number == nil
        return nil
      end

      return Household.new(
        dhs_number: r.dhs_number,
        size: r.household_size,
        income: Money.cents(r.household_income_cents),
        ownership: r.household_ownership.to_sym,
        is_primary_residence: r.household_primary_residence,
      )
    end
  end
end
