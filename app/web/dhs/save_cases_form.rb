module Dhs
  class SaveCasesForm
    def initialize(kase, form, case_repo: Case::Repo.get)
      @case_repo = case_repo
      @case = kase
      @form = form
    end

    # -- command --
    def call
      if not @form.valid?
        return false
      end

      @case.add_dhs_data(map_form_to_dhs_account)
      @case_repo.save_dhs_contribution(@case)

      true
    end

    # -- queries --
    private def map_form_to_dhs_account
      m = @form.mdhhs
      h = @form.household

      Recipient::DhsAccount.new(
        number: m.dhs_number,
        household: Recipient::Household.new(
          size: h.size.to_i,
          income_cents: (h.income.to_f * 100.0).to_i,
          ownership: h.ownership.nil? ? Recipient::Household::Ownership::Unknown : h.ownership,
          is_primary_residence: h.is_primary_residence.nil? ? true : h.is_primary_residence
        )
      )
    end
  end
end
