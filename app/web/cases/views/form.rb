module Cases
  module Views
    # A Case form object for modifying any writeable information.
    class Form < ApplicationForm
      # -- fields --
      field(:action, :symbol)

      # -- subforms --
      subform(:details, Cases::Forms::Details)
      subform(:address, Cases::Forms::Address)
      subform(:contact, Cases::Forms::Contact)
      subform(:household, Cases::Forms::Household)
      subform(:supplier_account, Cases::Forms::SupplierAccount)
      subform(:documents, Cases::Forms::Documents)
      subform(:admin, Cases::Forms::Admin)

      # -- queries --
      alias :detail :model

      # -- queries/validation
      def valid?
        status = @admin&.status || @model&.status

        scopes = []
        if action == :submit || Case::Status.submitted?(status)
          scopes.push(:submitted)
        end

        if action == :complete || Case::Status.complete?(status)
          scopes.push(:completed)
        end

        super(scopes)
      end

      # -- queries/transformation
      def map_to_admin
        return admin.status
      end

      def map_to_supplier_account
        return supplier_account.map_to_supplier_account
      end

      def map_to_recipient_profile
        return Recipient::Profile.new(
          phone: contact.map_to_recipient_phone,
          name: contact.map_to_recipient_name,
          address: address.map_to_recipient_address,
        )
      end

      def map_to_recipient_household
        return household.map_to_recipient_household
      end

      # -- ApplicationForm --
      def self.entity_type
        return Case
      end
    end
  end
end
