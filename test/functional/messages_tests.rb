require "test_helper"

class ChatMessagesTests < ActionDispatch::IntegrationTest
  # -- messages --
  test "rejects improperly signed requests" do
    post("/messages/twilio",
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
      "Body" => "hello",
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
      "http://#{host}/messages/twilio",
      params
    )

    act = -> do
      VCR.use_cassette("chats--recv-recipient-sms") do
        post("/messages/twilio", params: params,
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

    assert_broadcast_on(chat, {
      sender: Chat::Sender.recipient,
      message: {
        body: "Test from recipient.",
        timestamp: chat_message_timestamp,
        attachments: [],
      },
    })

    assert_broadcast_on(case_activity_for(:cohere_1), {
      name: "HAS_NEW_ACTIVITY",
      data: {
        case_id: case_rec.id,
        case_has_new_activity: true,
      }
    })
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
      "Body" => "hello test",
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
      "http://#{host}/messages/twilio",
      params
    )

    act = -> do
      VCR.use_cassette("chats--recv-recipient-sms--attachments") do
        post("/messages/twilio", params: params,
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

    assert_analytics_events(1) do |events|
      assert_match(/Did Receive Message/, events[0])
    end
  end
end
