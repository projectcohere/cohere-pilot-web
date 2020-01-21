class Chat < Entity
  prop(:record, default: nil)
  prop(:events, default: ArrayQueue::Empty)

  # -- props --
  prop(:id, default: Id::None)
  prop(:session, default: nil)
  prop(:messages, default: [])
  prop(:recipient_id)
  props_end!

  # -- props/temporary
  attr(:new_message)
  attr(:selected_message)

  # -- factories --
  def self.open(recipient_id, macro_repo: Macro::Repo.get)
    chat = Chat.new(
      recipient_id: recipient_id,
    )

    # add the intro / consent message
    macro = macro_repo.find_initial
    chat.add_message(
      sender: Sender::Automated,
      body: macro.body,
      attachments: macro.attachment == nil ? [] : [macro.attachment]
    )

    return chat
  end

  # -- commands --
  def start_session
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

  def select_message(i)
    if i >= @messages.count
      raise "can't select a message that does not exist"
    end

    @selected_message = @messages[i]
  end

  # -- callbacks --
  def did_save(record)
    @id.set(record.id)
    @record = record
  end

  def did_save_new_message
    @new_message = nil
  end
end
