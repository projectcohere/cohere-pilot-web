require "test_helper"

class ChatSmsTests < ActionDispatch::IntegrationTest
  include ActionCable::Channel::TestCase::Behavior

  # -- inbound --
  test "rejects an improperly signed inbound request" do
    post("/chats/sms/inbound",
      headers: {
        "X-Twilio-Signature" => "invalid-signature"
      },
    )

    assert_response(:forbidden)
  end

  test "adds a message" do
    params = {
      "ToCountry" => "US",
      "ToState" => "MI",
      "SmsMessageSid" => "SM4236d858e1c6eae2c235cbff5f5d8865",
      "NumMedia" => "0",
      "ToCity" => "",
      "FromZip" => "60090",
      "SmsSid" => "SM4236d858e1c6eae2c235cbff5f5d8865",
      "FromState" => "IL",
      "SmsStatus" => "received",
      "FromCity" => "WHEELING",
      "Body" => "Test from recipient.",
      "FromCountry" => "US",
      "To" => "+13132142937",
      "ToZip" => "",
      "NumSegments" => "1",
      "MessageSid" => "SM4236d858e1c6eae2c235cbff5f5d8865",
      "AccountSid" => ENV["TWILIO_API_ACCOUNT_SID"],
      "From" => "+12223334444",
      "ApiVersion" => "2010-04-01",
    }

    signature = Twilio::Signature.new(
      "http://#{host}/chats/sms/inbound",
      params
    )

    act = -> do
      VCR.use_cassette("chats--recv-recipient-sms") do
        post("/chats/sms/inbound", params: params,
          headers: {
            "X-Twilio-Signature" => signature.computed
          }
        )
      end
    end

    assert_difference(
      -> { Chat::Message::Record.count } => 1,
      &act
    )

    assert_matching_broadcast_on(chat_messages_for(:idle_2)) do |msg|
      assert_equal(msg["name"], "DID_ADD_MESSAGE")

      msg = msg["data"]
      assert_not_nil(msg["id"])
      assert_equal(msg["sender"], Chat::Sender.recipient)
      assert_equal(msg["body"], "Test from recipient.")
      assert_equal(msg["status"], Chat::Message::Status::Received.index)
      assert_not_nil(msg["timestamp"])
      assert_length(msg["attachments"], 0)
    end

    assert_matching_broadcast_on(case_activity_for(:agent_1)) do |msg|
      assert_equal(msg["name"], "HAS_NEW_ACTIVITY")
      assert(msg["data"]["case_new_activity"])
    end
  end

  test "adds a message with attachments" do
    params = {
      "ToCountry" => "US",
      "MediaContentType0" => "image/jpeg",
      "ToState" => "MI",
      "SmsMessageSid" => "MM598fb0ea354c2dca4fac7e148758f8e8",
      "NumMedia" => "1",
      "ToCity" => "",
      "FromZip" => "60090",
      "SmsSid" => "MM598fb0ea354c2dca4fac7e148758f8e8",
      "FromState" => "IL",
      "SmsStatus" => "received",
      "FromCity" => "WHEELING",
      "Body" => "Test from recipient.",
      "FromCountry" => "US",
      "To" => "+13132142937",
      "ToZip" => "",
      "NumSegments" => "1",
      "MessageSid" => "MM598fb0ea354c2dca4fac7e148758f8e8",
      "AccountSid" => ENV["TWILIO_API_ACCOUNT_SID"],
      "From" => "+12223334444",
      "MediaUrl0" => "https://api.twilio.com/2010-04-01/Accounts/#{ENV["TWILIO_API_ACCOUNT_SID"]}/Messages/MM598fb0ea354c2dca4fac7e148758f8e8/Media/MEbd4edd60eaca15bf1f5bd8be641d11ef",
      "ApiVersion" => "2010-04-01"
    }

    signature = Twilio::Signature.new(
      "http://#{host}/chats/sms/inbound",
      params
    )

    act = -> do
      VCR.use_cassette("chats--recv-recipient-sms--attachments") do
        post("/chats/sms/inbound", params: params,
          headers: {
            "X-Twilio-Signature" => signature.computed
          }
        )
      end
    end

    assert_difference(
      -> { Chat::Attachment::Record.count } => 1,
      -> { ActiveStorage::Blob.count } => 1,
      -> { Document::Record.count } => 1,
      &act
    )

    assert_response(:no_content)
    assert_analytics_events(%w[DidReceiveMessage])
  end

  # -- status --
  test "rejects an improperly signed status request" do
    post("/chats/sms/status",
      headers: {
        "X-Twilio-Signature" => "invalid-signature"
      },
    )

    assert_response(:forbidden)
  end

  test "updates a message's status" do
    message_rec = chat_messages(:message_i1_2)

    params = {
      "SmsSid" => "#{message_rec.remote_id}",
      "SmsStatus" => "delivered",
      "MessageStatus" => "delivered",
      "To" => "+12245882478",
      "MessageSid" => "#{message_rec.remote_id}",
      "AccountSid" => ENV["TWILIO_API_ACCOUNT_SID"],
      "From" => "+12223334444",
      "ApiVersion" => "2010-04-01"
    }

    signature = Twilio::Signature.new(
      "http://#{host}/chats/sms/status",
      params
    )

    act = -> do
      post("/chats/sms/status", params: params,
        headers: {
          "X-Twilio-Signature" => signature.computed
        }
      )
    end

    assert_changes(
      -> { message_rec.reload.status },
      &act
    )

    assert_matching_broadcast_on(chat_messages_for(:idle_1)) do |msg|
      assert_equal(msg["name"], "HAS_NEW_STATUS")
      assert_equal(msg["data"]["id"], message_rec.id)
      assert_equal(msg["data"]["status"], Chat::Message::Status::Delivered.index)
    end
  end
end
