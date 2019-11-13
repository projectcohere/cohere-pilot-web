module Users
  class InviteUser
    # -- lifetime --
    def get
      InviteUser.new
    end

    def initialize(
      user_repo: User::Repo.get,
      process_events: Events::ProcessAll.get
    )
      @user_repo = user_repo
      @process_events = process_events
    end

    # -- command --
    def call(email, role:)
      user = User.invite(email, role: role)
      @user_repo.save_invited(user)
      @process_events.()
    end
  end
end
