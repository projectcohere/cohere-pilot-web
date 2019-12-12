class Supplier
  class CasesForm < ApplicationForm
    # -- fields --
    subform(:address, Cases::Forms::Address)
    subform(:contact, Cases::Forms::Contact)
    subform(:supplier_account, Cases::Forms::SupplierAccount)

    # -- ApplicationForm --
    def self.entity_type
      Case
    end
  end
end
