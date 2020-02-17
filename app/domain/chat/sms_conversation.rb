class Chat
  class SmsConversation < ::Entity
    prop(:id, default: nil)
    prop(:notification, default: Notification::Clear)
    props_end!

    # -- queries --
    def reminder?
      @notification == Notification::Reminder1
    end

    # -- commands --
    def clear_reminder
      @notification = Notification::Clear
    end

    def remind_recipient
      @notification = Notification::Reminder1
    end
  end
end
