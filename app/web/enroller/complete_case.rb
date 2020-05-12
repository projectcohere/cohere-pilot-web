module Enroller
  class CompleteCase < ::Command
    # -- lifetime --
    def initialize(case_repo: Case::Repo.get)
      @case_repo = case_repo
    end

    # -- command --
    def call(id, status)
      kase = @case_repo.find_with_associations(id)
      kase.complete(Case::Status.from_key(status))
      @case_repo.save_completed(kase)
      return kase
    end
  end
end
