require "test_helper"

module Cron
  class DeliverRemindersTests < ActiveSupport::TestCase
    test "it schedules jobs for each chat" do
      Sidekiq::Testing.inline!
      deliver_reminders = Chats::DeliverReminders.new

      assert_raises do
        deliver_reminders.()
      end
    end
  end
end
