module Recipient
  class Household < ::Value
    prop(:size)
    prop(:income_cents)
    prop(:ownership, default: Ownership::Unknown)
    prop(:is_primary_residence, default: true)

    # -- queries --
    def income_dollars
      if income_cents.nil?
        return nil
      end

      income_cents / 100.0
    end
  end
end
