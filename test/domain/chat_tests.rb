require "test_helper"

class ChatTests < ActiveSupport::TestCase
  # -- factories --
  test "opens a chat with an initial message" do
    chat = Chat.open(1)
    assert_equal(chat.recipient_id, 1)

    message = chat.messages[0]
    assert_length(chat.messages, 1)
    assert_match(/Hi there/, message.body)

    # TODO: how can we stub out repos so that we can return mock
    # attachments in unit tests?
    # assert_length(message.attachments, 1)
  end

  # -- commands --
  test "starts a session" do
    chat = Chat.stub
    chat.start_session
    assert_not_nil(chat.session)
  end

  test "adds a message" do
    chat = Chat.stub(
      id: Id.new(42),
      messages: [
        Chat::Message.stub,
      ]
    )

    chat.add_message(
      sender: Chat::Sender.recipient,
      body: "This is a test.",
      attachments: []
    )

    assert_length(chat.messages, 2)

    message = chat.new_message
    assert_not_nil(message)
    assert_equal(message.id, Id::None)
    assert_equal(message.sender, Chat::Sender.recipient)
    assert_equal(message.body, "This is a test.")
    assert_equal(message.chat_id, 42)
    assert_length(message.attachments, 0)

    event = chat.events[0]
    assert_length(chat.events, 1)
    assert_instance_of(Chat::Events::DidAddMessage, event)
    assert_equal(event.chat_message_id, message.id)
    assert_not(event.has_attachments)
  end

  test "adds a message with attachments" do
    chat = Chat.stub(
      id: Id.new(42)
    )

    chat.add_message(
      sender: Chat::Sender.recipient,
      body: "This is a test.",
      attachments: ["test-file"]
    )

    message = chat.new_message
    assert_not_nil(message)
    assert_length(message.attachments, 1)

    event = chat.events[0]
    assert_instance_of(Chat::Events::DidAddMessage, event)
    assert_equal(event.chat_message_id, message.id)
    assert(event.has_attachments)
  end

  test "selects a message" do
    chat = Chat.stub(
      messages: [:test_message]
    )

    chat.select_message(0)
    assert_equal(chat.selected_message, :test_message)
  end
end
