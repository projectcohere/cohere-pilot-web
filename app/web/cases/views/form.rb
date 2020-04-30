module Cases
  module Views
    # A Case form object for modifying any writeable information.
    class Form < ApplicationForm
      # -- fields --
      field(:action, :symbol)
      field(:program_id, :integer)

      # -- subforms --
      subform(:details, Cases::Forms::Details)
      subform(:address, Cases::Forms::Address)
      subform(:contact, Cases::Forms::Contact)
      subform(:household, Cases::Forms::Household)
      subform(:supplier_account, Cases::Forms::SupplierAccount)
      subform(:documents, Cases::Forms::Documents)
      subform(:admin, Cases::Forms::Admin)

      # -- lifetime --
      protected def initialize_attrs(attrs)
        assign_defaults!(attrs, {
          program_id: @model.program.id,
        })
      end

      # -- queries --
      # -- queries/validation
      def valid?
        scopes = []

        status = @admin&.status || @model.try(:status)
        if action == :submit || Case::Status.submitted?(status) || action == :complete || Case::Status.complete?(status)
          scopes.push(:submitted)
        end

        if @model.try(:referred?) == true && @model.id == Id::None
          scopes.push(:new_referral)
        end

        super(scopes)
      end

      # -- queries/transformation
      def map_to_admin
        return admin.status
      end

      def map_to_supplier_account
        return supplier_account&.map_to_supplier_account
      end

      def map_to_profile
        return Recipient::Profile.new(
          phone: contact.map_to_recipient_phone,
          name: contact.map_to_recipient_name,
          address: address.map_to_recipient_address,
        )
      end

      def map_to_household
        return household.map_to_household
      end

      # -- ApplicationForm --
      def self.entity_type
        return Case
      end
    end
  end
end
