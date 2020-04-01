require "test_helper"

class ChatMessagesTests < ActionDispatch::IntegrationTest
  def setup
    # if you change the json, the signature below will also change. you'll need
    # to copy the `evaluated` signature from MessagesController#is_signed?...
    @params = {
      "MediaContentType1" => "image/jpeg",
      "ToCountry" => "US",
      "MediaContentType0" => "image/jpeg",
      "ToState" => "MI",
      "SmsMessageSid" => "MMaad3f908b1cd2a77a582b341c501d2a3",
      "NumMedia" => "2",
      "ToCity" => "",
      "FromZip" => "60090",
      "SmsSid" => "MMaad3f908b1cd2a77a582b341c501d2a3",
      "FromState" => "IL",
      "SmsStatus" => "received",
      "FromCity" => "WHEELING",
      "Body" => "with two",
      "FromCountry" => "US",
      "To" => "+13334445555",
      "MediaUrl1" => "https://api.twilio.com/2010-04-01/Accounts/#{ENV["TWILIO_API_ACCOUNT_SID"]}/Messages/MMaad3f908b1cd2a77a582b341c501d2a3/Media/MEd6dc9638afd3a87cc18a767e318550da",
      "ToZip" => "",
      "NumSegments" => "2",
      "MessageSid" => "MMaad3f908b1cd2a77a582b341c501d2a3",
      "AccountSid" => "#{ENV["TWILIO_API_ACCOUNT_SID"]}",
      "From" => "+12223334444",
      "MediaUrl0" => "https://api.twilio.com/2010-04-01/Accounts/#{ENV["TWILIO_API_ACCOUNT_SID"]}/Messages/MMaad3f908b1cd2a77a582b341c501d2a3/Media/ME39073178d12e9a479c17ea34785ab284",
      "ApiVersion" => "2010-04-01",
    }
  end

  # -- messages --
  test "rejects improperly signed requests" do
    post("/messages/twilio", params: @params,
      headers: {
        "X-Twilio-Signature" => "invalid-signature"
      },
    )

    assert_response(:forbidden)
  end

  test "processes message attachments" do
    signature = Twilio::Signature.new("http://#{host}/messages/twilio", @params)

    act = -> do
      VCR.use_cassette("chats--recv-recipient-mms") do
        post("/messages/twilio", params: @params,
          headers: {
            "X-Twilio-Signature" => signature.computed
          }
        )
      end
    end

    assert_difference(
      -> { Document::Record.count } => 2,
      -> { ActiveStorage::Attachment.count } => 2,
      -> { ActiveStorage::Blob.count } => 2,
      &act
    )

    assert_enqueued_jobs(2)
    assert_response(:no_content)

    assert_analytics_events(1) do |events|
      assert_match(/Did Receive Message/, events[0])
    end
  end
end
