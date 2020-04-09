require "test_helper"

class ChatsTests < ActionDispatch::IntegrationTest
  # -- files --
  test "can't upload without permission" do
    user_rec = users(:governor_1)
    chat_rec = chats(:idle_1)

    params = {
      files: {
        "0" => fixture_file_upload("files/test.txt", "text/plain")
      }
    }

    assert_raises(ActionController::RoutingError) do
      post("/chat/#{chat_rec.id}/files", params: params)
    end

    assert_raises(ActionController::RoutingError) do
      post(auth("/chat/#{chat_rec.id}/files", as: user_rec), params: params)
    end
  end

  test "can't upload files with an unknown request format" do
    assert_raises(ActionController::RoutingError) do
      post("/chat/files", as: :json)
    end
  end

  test "upload files as a cohere user" do
    user_rec = users(:cohere_1)
    chat_rec = chats(:idle_1)

    act = -> do
      post(auth("/chats/#{chat_rec.id}/files", as: user_rec), params: {
        files: {
          "0" => fixture_file_upload("files/test.txt", "text/plain")
        }
      })
    end

    assert_difference(
      -> { ActiveStorage::Blob.count } => 1,
      &act
    )

    assert_response(:success)

    res = JSON.parse(response.body)
    assert_length(res["data"]["fileIds"], 1)
  end
end
