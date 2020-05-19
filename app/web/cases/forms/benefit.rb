module Cases
  module Forms
    class Benefit < ApplicationForm
      include Case::Policy::Context::Shared
      include ActionView::Helpers::TranslationHelper

      # -- fields --
      field(:amount, :string, presence: { on: :approved })
      field(:contract, :symbol,
        presence: {
          on: :submitted,
          if: -> { permit?(:edit_contract) },
        },
      )

      # -- lifecycle --
      protected def initialize_attrs(attrs)
        assign_defaults!(attrs, {
          amount: @model.benefit&.dollars,
          contract: @model.contract&.source_url,
        })
      end

      # -- queries --
      def contract_options
        return contracts.map do |c|
          [t("program.contract.#{c.variant}", default: "program.contract.default"), c.variant]
        end
      end

      def contract_disabled?
        return contract.present?
      end

      private def contracts
        return @model.program.contracts
      end

      # -- transformation --
      def map_to_benefit
        return Money.dollars(amount)
      end

      def map_to_contract
        return contracts.find { |c| c.variant == contract }
      end

      # -- Case::Policy::Context --
      alias :case :model
    end
  end
end
