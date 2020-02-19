require "test_helper"

module Cron
  class SendNotificationsTests < ActiveSupport::TestCase
    test "it sends the notifcation as a new sms conversation" do
      send_notifications = Chats::SendNotifications.new
      chat_rec = chats(:idle_2)

      act = -> do
        VCR.use_cassette("chats--send-notifications") do
          send_notifications.()
          chat_rec.reload
        end
      end

      assert_changes(
        -> { chat_rec.sms_conversation_id },
        &act
      )
    end

    test "it sends the notification as a reply to an existing sms conversation" do
      send_notifications = Chats::SendNotifications.new
      chat_rec = chats(:idle_2)
      chat_rec.sms_conversation_id = "cnv_609wyrr"
      chat_rec.save!(touch: false)

      act = -> do
        VCR.use_cassette("chats--send-notifications--reply") do
          send_notifications.()
          chat_rec.reload
        end
      end

      assert_changes(
        -> { chat_rec.notification },
        &act
      )
    end
  end
end
