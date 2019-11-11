class Recipient
  class Household < ::Value
    prop(:size)
    prop(:income_cents)
    props_end!

    # -- queries --
    def income_dollars
      if income_cents.nil?
        return nil
      end

      income_cents / 100.0
    end
  end
end
