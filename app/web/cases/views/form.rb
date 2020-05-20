module Cases
  module Views
    # A Case form object for modifying all writeable attributes.
    class Form < ApplicationForm
      include ActionView::Helpers::TranslationHelper

      # -- props --
      attr(:action)

      # -- fields --
      field(:program_id, :integer)

      # -- subforms --
      subform(:contact, Cases::Forms::Contact)
      subform(:address, Cases::Forms::Address)
      subform(:household, Cases::Forms::Household)
      subform(:benefit, Cases::Forms::Benefit)
      subform(:supplier_account, Cases::Forms::SupplierAccount)
      subform(:food, Cases::Forms::Food)
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

        if @action&.approve? || status&.approved?
          scopes.push(:approved)
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

      def map_to_benefit
        return benefit.map_to_benefit
      end

      def map_to_contract
        return benefit.map_to_contract
      end

      def map_to_food
        return food&.map_to_food
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
