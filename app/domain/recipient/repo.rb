module Recipient
  module Repo
    # -- factories --
    def self.map_profile(r)
      return Profile.new(
        phone: map_phone(r),
        name: map_name(r),
        address: map_address(r),
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
      return Household.new(
        dhs_number: r.dhs_number,
        size: r.household_size,
        proof_of_income: ProofOfIncome.from_key(r.household_proof_of_income),
        income: Money.cents(r.household_income_cents),
        ownership: Ownership.from_key(r.household_ownership),
      )
    end
  end
end
