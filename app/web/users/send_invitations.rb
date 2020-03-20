require "csv"

module Users
  class SendInvitations < ::Command
    # -- lifetime --
    def initialize(
      user_repo: User::Repo.get,
      process_events: Events::ProcessAll.get
    )
      @user_repo = user_repo
      @process_events = process_events
    end

    # -- command --
    def call(invitation_csv)
      invitation_rows = CSV.parse(invitation_csv, headers: true)
      invitations = invitation_rows.map do |row|
        decode_invitation(row)
      end

      invitations.each do |invitation|
        user = User.invite(invitation)
        @user_repo.save_invited(user)
        @process_events.()
      end
    end

    # -- command/helpers
    private def decode_invitation(row)
      User::Invitation.new(
        email: row[0],
        partner_id: row[1],
      )
    end
  end
end
