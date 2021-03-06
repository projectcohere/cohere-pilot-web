module Recipient
  class Household < ::Value
    # -- props --
    prop(:dhs_number, default: nil)
    prop(:size, default: nil)
    prop(:proof_of_income)
    prop(:income, default: nil)
    prop(:ownership, default: Ownership::Unknown)

    # -- queries --
    def fpl_percent
      if @size == nil || @income == nil
        return nil
      end

      hh_month_cents = @income.cents
      hh_year_cents = hh_month_cents * 12

      fpl_month_cents = 1580_00 + (@size - 1) * 540_00
      fpl_year_cents = fpl_month_cents * 8

      fpl_percent = 100 * hh_year_cents / fpl_year_cents.to_f
      fpl_percent = fpl_percent.round(0)

      return fpl_percent
    end
  end
end
