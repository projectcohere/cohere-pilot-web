module Cases
  class ActivityChannel < ApplicationCable::Channel
    # -- ActionCable::Channel::Base
    def subscribed
      stream_for(find_partner_id)
    end

    private def find_partner_id
      return connection.user.role.partner_id
    end
  end
end
