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
      def initialize(model, attrs = {}, program_repo: Program::Repo.get)
        @program_repo = program_repo
        super(model, attrs)
      end

      protected def initialize_attrs(attrs)
        assign_defaults!(attrs, {
          contract_variant: @model.documents.find { |d| d.classification == :contract }&.source_url
        })
      end

      # -- queries --
      # -- queries/contract
      def selected_contract
        if not contract_variant.nil?
          contracts.find { |c| c.variant == contract_variant }
        end
      end

      def contracts
        @program_repo.find_by_name(@model.program).contracts
      end

      def contract_options
        contracts.map do |c, i|
          [name_from_contract_variant(c.variant), c.variant]
        end
      end

      # -- queries/contract/helpers
      private def name_from_contract_variant(variant)
        case variant
        when Program::Contract::Meap
          "MEAP"
        when Program::Contract::Wrap3h
          "WRAP ($300)"
        when Program::Contract::Wrap1k
          "WRAP ($1000)"
        end
      end
    end
  end
end
