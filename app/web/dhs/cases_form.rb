module Dhs
  class CasesForm < ApplicationForm
    # -- fields --
    subform(:mdhhs, Cases::Forms::Mdhhs)
    subform(:household, Cases::Forms::Household)

    # -- queries --
    def map_to_recipient_dhs_account
      Recipient::DhsAccount.new(
        number: mdhhs.dhs_number,
        household: household.map_to_recipient_household,
      )
    end

    # -- ApplicationForm --
    def self.entity_type
      Case
    end
  end
end
