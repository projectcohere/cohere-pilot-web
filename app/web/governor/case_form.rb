module Governor
  class CaseForm < ApplicationForm
    # -- fields --
    subform(:household, Cases::Forms::Household)

    # -- queries --
    def map_to_recipient_household
      return household.map_to_recipient_household
    end

    # -- ApplicationForm --
    def self.entity_type
      return Case
    end
  end
end
