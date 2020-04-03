module Users
  class Mailer < ApplicationMailer
    def did_invite(user_id)
      @user = User::Repo.get.find(user_id)

      mail(
        subject: "You're invited to the Cohere Pilot!",
        to: @user.email
      )
    end
  end
end
