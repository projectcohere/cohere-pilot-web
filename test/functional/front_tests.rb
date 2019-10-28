require "test_helper"

class FrontTests < ActionDispatch::IntegrationTest
  # -- index --
  test "rejects improperly signed requests" do
    body = '{
      "target": {
        "data": {
          "recipients": [
            {"handle": "1", "role": "from"}
          ]
        }
      }
    }'

    post("/front/messages", params: body,
      headers: {
        "X-Front-Signature" => "invalid-signature"
      },
    )

    assert_response(:unauthorized)
  end

  test "processes messages" do
    # if you change the body, the signature will also change. you'll
    # need to copy the `evaluated` signature from FrontController#is_signed?
    # into the headers below.
    body = '{
      "target": {
        "data": {
          "recipients": [
            {"handle": "1", "role": "from"}
          ]
        }
      }
    }'

    post("/front/messages", params: body,
      headers: {
        "X-Front-Signature" => "7ACjXHlDc0Oks0gt9pEEDOYCbrk="
      }
    )

    assert_response(:no_content)
  end
end
