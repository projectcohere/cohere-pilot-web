module Enroller
  class ReturnCaseToAgent < ::Command
    # -- lifetime --
    def initialize(case_repo: Case::Repo.get)
      @case_repo = case_repo
    end

    # -- command --
    def call(kase)
      kase.return_to_agent
      @case_repo.save_returned(kase)
    end
  end
end
