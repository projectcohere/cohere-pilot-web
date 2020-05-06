require "csv"

module Users
  class SendInvitations < ::Command
    # -- lifetime --
    def initialize(
      user_repo: User::Repo.get,
      partner_repo: Partner::Repo.get
    )
      @user_repo = user_repo
      @partner_repo = partner_repo
    end

    # -- command --
    def call(invitation_csv)
      rows = CSV.parse(invitation_csv, headers: true)
      rows.each do |row|
        user = User.invite(decode_invitation(row))
        @user_repo.save_invited(user)

        # fire events
        Events::DispatchAll.()
      end
    end

    # -- command/helpers
    private def decode_invitation(row)
      partner_id = row[1]

      role_key = row[2]
      role = if role_key != nil
        Role.from_key(role_key)
      else
        @partner_repo.find(partner_id).default_role
      end

      User::Invitation.new(
        email: row[0],
        role: role,
        partner_id: partner_id,
      )
    end
  end
end
