require "test_helper"
require "sidekiq/testing"

class MessagesTests < ActionDispatch::IntegrationTest
  def setup
    # if you change the json, the signature will also change. you'll need
    # to copy the `evaluated` signature from FrontController#is_signed?
    # into the headers below.
    @json = <<-JSON.chomp
      {
        "target": {
          "data": {
            "recipients": [
              { "handle": "#{recipients(:recipient_1).phone_number}", "role": "from" }
            ],
            "attachments": [
              { "url": "https://website.com/image.jpg" }
            ]
          }
        }
      }
    JSON
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
    Sidekiq::Testing.inline!

    act = -> do
      post("/messages/front", params: @json,
        headers: {
          "X-Front-Signature" => "8RfkwzcQMyV3AEqpRKDDPuhk3ps="
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
