module Cases
  # A form object for all the case info
  class Form < ApplicationForm
    # -- fields --
    subform(:details, Forms::Details)
    subform(:address, Forms::Address)
    subform(:contact, Forms::Contact)
    subform(:household, Forms::Household)
    subform(:mdhhs, Forms::Mdhhs)
    subform(:supplier_account, Forms::SupplierAccount)

    # -- ApplicationForm --
    def self.entity_type
      Case
    end
  end
end
