require "test_helper"

class FrontTests < ActionDispatch::IntegrationTest
  # -- index --
  test "rejects improperly signed requests" do
    post("/front/messages",
      params: '{"test": "body"}',
      headers: {
        "X-Front-Signature" => "invalid-signature"
      },
    )

    assert_response(:unauthorized)
  end

  test "processes messages" do
    body =

    post("/front/messages",
      params: '{"test": "body"}',
      headers: {
        "X-Front-Signature" => "MQQkiJRgC+UCPeqX2hQVXOylpVg="
      }
    )

    assert_response(:no_content)
  end
end
