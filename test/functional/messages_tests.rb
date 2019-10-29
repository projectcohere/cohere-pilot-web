require "test_helper"
require "sidekiq/testing"

class MessagesTests < ActionDispatch::IntegrationTest
  def setup
    # if you change the json, the signature below will also change. you'll need
    # to copy the `evaluated` signature from FrontController#is_signed?...
    @json = <<-JSON.chomp
      {
        "target": {
          "data": {
            "recipients": [
              { "handle": "#{recipients(:recipient_1).phone_number}", "role": "from" }
            ],
            "attachments": [
              { "url": "https://api2.frontapp.com/download/fil_atg8kcn" }
            ]
          }
        }
      }
    JSON

    # ...and paste it here
    @signature = "g/ELqY94sQz2WElVIf1NDz7arzo="
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
        -> { Recipient::Document::Record.count } => 1,
        &act
      )

      assert_response(:no_content)
    end
  end
end
