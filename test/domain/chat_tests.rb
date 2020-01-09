require "test_helper"

class ChatTests < ActiveSupport::TestCase
  # -- commands --
  test "starts a session" do
    chat = Chat.stub(
      invitation: Chat::Invitation.stub
    )

    chat.start_session
    assert_nil(chat.invitation)
    assert_not_nil(chat.session)
  end

  test "adds a message" do
    chat = Chat.stub(
      id: Id.new(42),
      messages: [
        Chat::Message.stub,
        Chat::Message.stub,
      ]
    )

    chat.add_message(
      sender: Chat::Sender.recipient,
      body: "This is a test.",
    )

    assert_length(chat.messages, 3)
    assert_length(chat.new_messages, 1)

    message = chat.new_messages[0]
    assert_equal(message.id, Id::None)
    assert_equal(message.sender, Chat::Sender.recipient)
    assert_equal(message.body, "This is a test.")
    assert_equal(message.chat_id, 42)

    assert_length(chat.events, 1)
    assert_instance_of(Chat::Events::DidReceiveMessage, chat.events[0])
    assert_not_nil(chat.events[0].chat_message_id)
  end
end
