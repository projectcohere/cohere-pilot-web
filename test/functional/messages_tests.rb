require "test_helper"

class MessagesTests < ActionDispatch::IntegrationTest
  # -- index --
  test "processes messages in a worker" do
    post("/front/messages", params: '{ "name": "test" }', as: :json)
    assert_response(:success)
  end
end
