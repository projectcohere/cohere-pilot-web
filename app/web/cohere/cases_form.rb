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

    # -- queries --
    def map_to_case_supplier_account
      supplier_account.map_to_case_supplier_account
    end

    def map_to_recipient_profile
      Recipient::Profile.new(
        phone: contact.map_to_recipient_phone,
        name: contact.map_to_recipient_name,
        address: address.map_to_recipient_address,
      )
    end

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
