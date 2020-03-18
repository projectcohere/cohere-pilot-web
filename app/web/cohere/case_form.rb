module Cohere
  # A form object for all the case info
  class CaseForm < ApplicationForm
    # -- fields --
    subform(:details, Cases::Forms::Details)
    subform(:address, Cases::Forms::Address)
    subform(:contact, Cases::Forms::Contact)
    subform(:household, Cases::Forms::Household)
    subform(:mdhhs, Cases::Forms::Mdhhs)
    subform(:supplier_account, Cases::Forms::SupplierAccount)
    subform(:documents, Cases::Forms::Documents)
    subform(:admin, Cases::Forms::Admin)

    # -- queries --
    # -- queries/transformation
    def map_to_admin
      return admin.status
    end

    def map_to_case_supplier_account
      return supplier_account.map_to_case_supplier_account
    end

    def map_to_recipient_profile
      return Recipient::Profile.new(
        phone: contact.map_to_recipient_phone,
        name: contact.map_to_recipient_name,
        address: address.map_to_recipient_address,
      )
    end

    def map_to_recipient_dhs_account
      return Recipient::DhsAccount.new(
        number: mdhhs.dhs_number,
        household: household.map_to_recipient_household,
      )
    end

    # -- ApplicationForm --
    def self.entity_type
      return Case
    end
  end
end
