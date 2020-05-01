module Cases
  module Forms
    class Contract < ApplicationForm
      include Case::Policy::Context::Shared
      include ActionView::Helpers::TranslationHelper

      # -- fields --
      field(:variant, :symbol,
        presence: {
          on: :submitted,
          if: -> { permit?(:edit_contract) },
        },
      )

      # -- lifecycle --
      protected def initialize_attrs(attrs)
        assign_defaults!(attrs, {
          variant: @model.contract&.source_url,
        })
      end

      # -- queries --
      def disabled?
        return variant.present?
      end

      def variant_options
        return contracts.map do |c|
          [t("program.contract.#{c.variant}", default: "program.contract.default"), c.variant]
        end
      end

      private def contracts
        return @model.program.contracts
      end

      # -- transformation --
      def map_to_contract
        return contracts.find { |c| c.variant == variant }
      end

      # -- Case::Policy::Context --
      alias :case :model
    end
  end
end
