module Supplier
  class CaseForm < ApplicationForm
    # -- fields --
    subform(:address, Cases::Forms::Address)
    subform(:contact, Cases::Forms::Contact)
    subform(:supplier_account, Cases::Forms::SupplierAccount)

    # -- queries --
    def map_to_supplier_account
      supplier_account.map_to_supplier_account
    end

    def map_to_recipient_profile
      Recipient::Profile.new(
        phone: contact.map_to_recipient_phone,
        name: contact.map_to_recipient_name,
        address: address.map_to_recipient_address,
      )
    end

    # -- ApplicationForm --
    def self.entity_type
      Case
    end
  end
end
