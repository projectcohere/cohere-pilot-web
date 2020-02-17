class Chat
  module Notification
    # -- options --
    Clear = :clear
    Reminder1 = :reminder_1

    # -- queries --
    def self.all
      @all ||= [
        Clear,
        Reminder1,
      ]
    end
  end
end
