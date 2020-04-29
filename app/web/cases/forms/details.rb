module Cases
  module Forms
    class Details < ApplicationForm
      include Case::Policy::Context::Shared

      # -- fields --
      field(:contract_variant, :symbol, presence: { on: :submitted, if: :required? })

      # -- lifecycle --
      protected def initialize_attrs(attrs)
        assign_defaults!(attrs, {
          contract_variant: @model.contract&.source_url,
        })
      end

      # -- queries --
      private def required?
        return permit?(:edit_contract)
      end

      # -- queries/contract
      def selected_contract
        return contracts.find { |c| c.variant == contract_variant }
      end

      def contract_options
        return contracts.map do |c|
          [name_from_contract_variant(c.variant), c.variant]
        end
      end

      private def contracts
        return @model.program.contracts
      end

      # -- queries/contract/helpers
      private def name_from_contract_variant(variant)
        case variant
        when :meap
          "MEAP"
        when :wrap_3h
          "WRAP ($300)"
        when :wrap_1k
          "WRAP ($1000)"
        else
          "Unknown"
        end
      end

      # -- Case::Policy::Context --
      alias :case :model
    end
  end
end
