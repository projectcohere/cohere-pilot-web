require "test_helper"

class ChatTests < ActiveSupport::TestCase
  def stub_recipient
    return Chat::Recipient.stub(
      profile: Recipient::Profile.stub(
        name: Recipient::Name.stub,
      ),
    )
  end

  # -- factories --
  test "opens a chat with an initial message" do
    chat = Chat.open(stub_recipient)
    assert_not_nil(chat.recipient)

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

  # -- commands/messages
  test "adds a message" do
    chat = Chat.stub(
      id: Id.new(42),
      recipient: stub_recipient,
      messages: [Chat::Message.stub]
    )

    chat.add_message(
      sender: Chat::Sender.cohere(:test_sender),
      body: "This is a test.",
      attachments: %i[test_attachment]
    )

    assert_length(chat.messages, 2)

    message = chat.new_message
    assert_not_nil(message)
    assert_equal(message.id, Id::None)
    assert_equal(message.sender, :test_sender)
    assert_equal(message.body, "This is a test.")
    assert_equal(message.chat_id, 42)

    attachment = message.attachments[0]
    assert_length(message.attachments, 1)
    assert_equal(attachment, :test_attachment)

    event = chat.events[0]
    assert_length(chat.events, 1)
    assert_instance_of(Chat::Events::DidAddMessage, event)
    assert_equal(event.chat_message_id, message.id)
  end

  test "selects a message" do
    chat = Chat.stub(
      messages: [:test_message]
    )

    chat.select_message(0)
    assert_equal(chat.selected_message, :test_message)
  end
end
