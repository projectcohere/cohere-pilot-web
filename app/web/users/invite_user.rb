module Users
  class InviteUser
    # -- lifetime --
    def get
      InviteUser.new
    end

    def initialize(
      user_repo: User::Repo.get,
      process_event_queue: ProcessEventQueue.get
    )
      @user_repo = user_repo
      @process_event_queue = process_event_queue
    end

    # -- command --
    def call(email, role:)
      user = User.invite(email, role: role)
      @user_repo.save_invited(user)
      @process_event_queue.()
    end
  end
end
