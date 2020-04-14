class Program
  class Repo
    include Service

    # -- queries --
    def find_by_name(name)
      contract_variants = find_contract_variants_by_name(name)

      Program.new(
        id: name,
        contracts: contract_variants.map { |variant|
          Program::Contract.new(program: name, variant: variant)
        }
      )
    end

    private def find_contract_variants_by_name(name)
      case name
      when Program::Name::Meap
        [Program::Contract::Meap]
      when Program::Name::Wrap
        [Program::Contract::Wrap3h, Program::Contract::Wrap1k]
      end
    end
  end
end
