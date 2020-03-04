require "test_helper"

class MessagesTests < ActionDispatch::IntegrationTest
  def setup
    # if you change the json, the signature below will also change. you'll need
    # to copy the `evaluated` signature from MessagesController#is_signed?...
    @json = <<-JSON.chomp
      {
        "target": {
          "data": {
            "recipients": [
              { "handle": "+1#{recipients(:recipient_1).phone_number}", "role": "from" },
              { "handle": "+1#{ENV["FRONT_API_PHONE_NUMBER"]}", "role": "to" }
            ],
            "attachments": [
              { "url": "https://api2.frontapp.com/download/fil_atg8kcn" }
            ]
          }
        }
      }
    JSON

    # ...and paste it here
    @signature = "qMrKrW2lybzD/7xXxKjBEFVOYX0="
  end

  # -- messages --
  test "rejects improperly signed requests" do
    post("/messages/front", params: @json,
      headers: {
        "X-Front-Signature" => "invalid-signature"
      },
    )

    assert_response(:unauthorized)
  end

  test "processes message attachments" do
    act = -> do
      VCR.use_cassette("front--attachment") do
        post("/messages/front", params: @json,
          headers: {
            "X-Front-Signature" => @signature
          }
        )
      end
    end

    assert_difference(
      -> { Document::Record.count } => 1,
      -> { ActiveStorage::Attachment.count } => 1,
      -> { ActiveStorage::Blob.count } => 1,
      &act
    )

    assert_enqueued_jobs(1)
    assert_response(:no_content)

    assert_analytics_events(1) do |events|
      assert_match(/Did Receive Message/, events[0])
    end
  end
end
