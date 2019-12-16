module Cohere
  # A form object for all the case info
  class CasesForm < ApplicationForm
    # -- fields --
    subform(:details, Cases::Forms::Details)
    subform(:address, Cases::Forms::Address)
    subform(:contact, Cases::Forms::Contact)
    subform(:household, Cases::Forms::Household)
    subform(:mdhhs, Cases::Forms::Mdhhs)
    subform(:supplier_account, Cases::Forms::SupplierAccount)

    # -- ApplicationForm --
    def self.entity_type
      Case
    end
  end
end
