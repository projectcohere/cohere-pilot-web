class Chat < Entity
  prop(:record, default: nil)
  prop(:events, default: ArrayQueue::Empty)

  # -- props --
  prop(:id, default: Id::None)
  prop(:recipient_token, default: nil)
  prop(:messages, default: [])
  prop(:current_case_id, default: nil)
  props_end!

  # -- props/temporary
  attr(:new_messages)

  # -- commands --
  def add_message(sender:, type:, body:)
    message = Message.new(
      sender: sender,
      type: type,
      body: body,
      chat_id: @id.val,
    )

    @messages << message

    @new_messages ||= []
    @new_messages << message

    @events << Events::DidReceiveMessage.from_entity(self)
  end

  # -- callbacks --
  def did_save_new_messages
    @new_messages = nil
  end
end
