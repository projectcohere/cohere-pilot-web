module Dhs
  class CasesForm < ApplicationForm
    # -- fields --
    subform(:mdhhs, Cases::Forms::Mdhhs)
    subform(:household, Cases::Forms::Household)

    # -- ApplicationForm --
    def self.entity_type
      Case
    end
  end
end
