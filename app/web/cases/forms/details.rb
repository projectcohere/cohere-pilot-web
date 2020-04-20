module Cases
  module Forms
    class Details < ApplicationForm
      # -- fields --
      field(:contract_variant, :symbol,
        on: {
          submitted: { presence: true },
          completed: { presence: true },
        },
      )

      # -- lifecycle --
      protected def initialize_attrs(attrs)
        assign_defaults!(attrs, {
          contract_variant: @model.documents.find { |d| d.classification == :contract }&.source_url,
        })
      end

      # -- queries --
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
    end
  end
end
