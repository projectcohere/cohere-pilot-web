module Cases
  class ConvertProgram < ::Command
    # -- lifetime --
    def initialize(
      case_repo: Case::Repo.get,
      program_repo: Program::Repo.get
    )
      @case_repo = case_repo
      @program_repo = program_repo
    end

    # -- command --
    def call(id, program_id)
      kase = @case_repo.find(id)
      kase.convert_to_program(
        @program_repo.find_available(kase.recipient.id.val, program_id)
      )

      @case_repo.save_converted(kase)

      return kase
    end
  end
end
