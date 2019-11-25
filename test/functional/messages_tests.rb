require "test_helper"

class MessagesTests < ActionDispatch::IntegrationTest
  def setup
    # if you change the json, the signature below will also change. you'll need
    # to copy the `evaluated` signature from FrontController#is_signed?...
    @json = <<-JSON.chomp
      {
        "target": {
          "data": {
            "recipients": [
              { "handle": "+1#{recipients(:recipient_1).phone_number}", "role": "from" }
            ],
            "attachments": [
              { "url": "https://api2.frontapp.com/download/fil_atg8kcn" }
            ]
          }
        }
      }
    JSON

    # ...and paste it here
    @signature = "q6gpVNetS/5dH4e0km0nMttDW6I="
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
    VCR.use_cassette("front--attachment") do
      Sidekiq::Testing.inline!

      act = -> do
        post("/messages/front", params: @json,
          headers: {
            "X-Front-Signature" => @signature
          }
        )
      end

      assert_difference(
        -> { Document::Record.count } => 1,
        -> { ActiveStorage::Attachment.count } => 1,
        -> { ActiveStorage::Blob.count } => 1,
        &act
      )

      assert_enqueued_jobs(1)
      assert_response(:no_content)

      assert_analytics_events(1)
      assert_match(/Did Receive Message/, analytics_events[0])
    end
  end
end
