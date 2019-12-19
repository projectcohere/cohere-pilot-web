class Chat < Entity
  prop(:record, default: nil)
  prop(:events, default: ArrayQueue::Empty)

  # -- props --
  prop(:id, default: Id::None)
  prop(:recipient_token, default: nil)
  prop(:messages, default: [])
  props_end!

  # -- props/temporary
  attr(:new_messages)
  attr(:selected_message)

  # -- commands --
  def add_message(sender:, type:, body:)
    message = Message.new(
      id: messages.count,
      sender: sender,
      type: type,
      body: body
   )

    @messages << message

    @new_messages ||= []
    @new_messages << message

    @events << Events::DidReceiveMessage.from_entity(self)
  end

  # -- commands/selection
  def select_message(i)
    if i >= @messages.count
      raise "tried to select a message that didn't exist"
    end

    @selected_message = @messages[i]
  end

  # -- callbacks --
  def did_save_new_messages
    @new_messages = nil
  end
end
