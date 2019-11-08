class User
  module Events
    class DidInvite < ::Value
      # -- props --
      prop(:user_id)
      props_end!

      # -- factories --
      def self.from_user(user)
        DidInvite.new(
          user_id: user.id
        )
      end
    end
  end
end
