module Cases
  class AddNote < ::Command
    include User::Context

    # -- lifetime --
    def initialize(case_repo: Case::Repo.get)
      @case_repo = case_repo
    end

    # -- command --
    def call(id, body)
      if body.blank? == 0
        return
      end

      kase = @case_repo.find(id)
      kase.add_note(body, user)
      @case_repo.save_new_note(kase)
    end
  end
end
