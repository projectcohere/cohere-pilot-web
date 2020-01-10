class Chat < Entity
  prop(:record, default: nil)
  prop(:events, default: ArrayQueue::Empty)

  # -- props --
  prop(:id, default: Id::None)
  prop(:session, default: nil)
  prop(:invitation, default: nil)
  prop(:messages, default: [])
  prop(:current_case_id, default: nil)
  props_end!

  # -- props/temporary
  attr(:new_message)

  # -- commands --
  def start_session
    @invitation = nil
    @session = SecureRandom.base58
  end

  def add_message(sender:, body:, attachments:)
    message = Message.new(
      sender: sender,
      body: body,
      attachments: attachments,
      chat_id: @id.val,
    )

    @new_message = message
    @messages << message
    @events << Events::DidAddMessage.from_entity(self)
  end

  # -- callbacks --
  def did_save_new_message
    @new_message = nil
  end
end
