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
      files: [
        :test_io,
        Sms::Media.stub(url: :test_url),
      ]
    )

    messages = chat.messages
    assert_length(messages, 2)

    message = chat.new_message
    assert_not_nil(message)
    assert_equal(message.id, Id::None)
    assert_equal(message.sender, :test_sender)
    assert_equal(message.body, "This is a test.")
    assert_equal(message.chat_id, 42)

    attachments = message.attachments
    assert_length(attachments, 2)

    attachment = attachments[0]
    assert_equal(attachment.file, :test_io)

    attachment = attachments[1]
    assert(attachment.remote?)
    assert_equal(attachment.remote_url, :test_url)

    events = chat.events
    assert_instances_of(events, [
      Chat::Events::DidPrepareMessage,
      Chat::Events::DidAddRemoteAttachment,
    ])
  end

  test "selects a message" do
    chat = Chat.stub(
      messages: [:test_message]
    )

    chat.select_message(0)
    assert_equal(chat.selected_message, :test_message)
  end

  # -- commands/attachments
  test "selects an attachment" do
    chat = Chat.stub(
      messages: [
        Chat::Message.stub(
          attachments: [Chat::Attachment.stub(id: Id.new(3))],
        ),
      ],
    )

    chat.select_message(0)
    chat.selected_message.select_attachment(3)
    assert_equal(chat.selected_attachment.id.val, 3)
  end

  test "uploads an attachment" do
    chat = Chat.stub(
      messages: [
        Chat::Message.stub(
          attachments: [Chat::Attachment.stub(id: Id.new(3))],
        ),
      ],
    )

    chat.select_message(0)
    chat.selected_message.select_attachment(3)

    chat.upload_selected_attachment(:test_file)
    assert_not(chat.selected_attachment.remote?)
    assert_instances_of(chat.events, [Chat::Events::DidUploadAttachment])
  end
end
