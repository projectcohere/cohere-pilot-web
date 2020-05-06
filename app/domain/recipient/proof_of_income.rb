module Recipient
  class ProofOfIncome < ::Option
    # -- options --
    option(:dhs)
    option(:wrap)
    option(:meap)
    option(:ec_program)
    option(:weatherization)
    option(:uia)
    option(:ssi_ssdi)
    option(:pension_retirement)
    option(:military)
    option(:paystubs)
    option(:layoff)
    option(:hptap_pays)
    option(:attested_income)
    option(:attested_no_income)

    # -- queries --
    def dhs?
      return self == Dhs
    end

    def attested?
      return self == AttestedIncome || self == AttestedNoIncome
    end

    def document?
      return !dhs? && !attested?
    end
  end
end
