module Cases
  class ActivityChannel < ActionCable::Channel::Base
    Active = :active

    # -- ActionCable::Channel::Base
    def subscribed
      puts "subscribed to activity channel"
      stream_for(Active)
    end

    # -- queries --
    def self.active
      return broadcasting_for(Active)
    end
  end
end
