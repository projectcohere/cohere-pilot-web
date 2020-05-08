module Enroller
  class CompleteCase < ::Command
    # -- lifetime --
    def initialize(case_repo: Case::Repo.get)
      @case_repo = case_repo
    end

    # -- command --
    def call(kase, status)
      kase.complete(Case::Status.from_key(status))
      @case_repo.save_completed(kase)
    end
  end
end
