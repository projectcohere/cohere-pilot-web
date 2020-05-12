module Cases
  module Views
    # A Case form object for modifying any writeable information.
    class Form < ApplicationForm
      include ActionView::Helpers::TranslationHelper

      # -- props --
      attr(:action)

      # -- fields --
      field(:program_id, :integer)

      # -- subforms --
      subform(:contract, Cases::Forms::Contract)
      subform(:address, Cases::Forms::Address)
      subform(:contact, Cases::Forms::Contact)
      subform(:household, Cases::Forms::Household)
      subform(:supplier_account, Cases::Forms::SupplierAccount)
      subform(:documents, Cases::Forms::Documents)
      subform(:admin, Cases::Forms::Admin)

      # -- lifetime --
      def initialize(model, action, attrs = {}, &permit)
        @action = action
        super(model, attrs, &permit)
      end

      protected def initialize_attrs(attrs)
        assign_defaults!(attrs, {
          program_id: @model.program.id,
        })
      end

      # -- queries --
      def action_text
        return @action != nil ? t("cases.action.#{@action.key}") : nil
      end

      # -- queries/validation
      def valid?
        scopes = []

        status = @admin&.map_to_status || @model.try(:status)
        if @action&.submit? || status&.submitted? || @action&.complete? || status&.complete?
          scopes.push(:submitted)
        end

        super(scopes)
      end

      # -- queries/transformation
      def map_to_profile
        return Recipient::Profile.new(
          phone: contact.map_to_recipient_phone,
          name: contact.map_to_recipient_name,
          address: address.map_to_recipient_address,
        )
      end

      def map_to_household
        return household&.map_to_household
      end

      def map_to_supplier_account
        return supplier_account&.map_to_supplier_account
      end

      def map_to_contract
        return contract&.map_to_contract
      end

      def map_to_admin
        return admin&.map_to_status
      end

      # -- ApplicationForm --
      def self.entity_type
        return Case
      end
    end
  end
end
