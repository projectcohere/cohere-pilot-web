module Cases
  class ActivityChannel < ApplicationCable::Channel
    # -- ActionCable::Channel::Base --
    def subscribed
      stream_for(user_stream)
    end

    # -- helpers --
    def user_stream
      user = connection.user
      return self.class.role_stream(user.role, user.partner_id)
    end

    def self.role_stream(role, partner_id)
      return "#{role}@#{partner_id}"
    end
  end
end
