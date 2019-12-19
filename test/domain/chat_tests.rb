require "test_helper"

class ChatTests < ActiveSupport::TestCase
  # -- commands --
  test "add a message" do
    chat = Chat.stub(
      messages: [
        Chat::Message.stub,
        Chat::Message.stub,
      ]
    )

    chat.add_message(
      sender: Chat::Sender::Recipient,
      type: Chat::Type::Text,
      body: "This is a test.",
    )

    assert_length(chat.messages, 3)
    assert_length(chat.new_messages, 1)

    message = chat.new_messages[0]
    assert_equal(message.id, 2)
    assert_equal(message.sender, Chat::Sender::Recipient)
    assert_equal(message.type, Chat::Type::Text)
    assert_equal(message.body, "This is a test.")

    assert_length(chat.events, 1)
    assert_instance_of(Chat::Events::DidReceiveMessage, chat.events[0])
  end

  # -- commands/selection
  test "selects a message" do
    chat = Chat.stub(messages: [Chat::Message.stub])

    chat.select_message(0)
    assert_equal(chat.selected_message, chat.messages[0])
  end

  test "doesn't select a missing message" do
    kase = Case.stub

    assert_raises do
      chat.select_message(0)
    end
  end
end
