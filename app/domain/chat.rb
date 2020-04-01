class Chat < Entity
  prop(:record, default: nil)
  prop(:events, default: ArrayQueue::Empty)

  # -- props --
  prop(:id, default: Id::None)
  prop(:recipient)
  prop(:messages, default: [])

  # -- props/temporary
  attr(:new_message)
  attr(:selected_message)

  # -- factories --
  def self.open(recipient, macro_repo: Macro::Repo.get)
    chat = Chat.new(
      recipient: recipient,
    )

    # add the intro / consent message
    macro = macro_repo.find_initial
    chat.add_message(
      sender: Sender.automated,
      body: macro.body,
      attachments: macro.attachment == nil ? [] : [macro.attachment]
    )

    return chat
  end

  # -- queries --
  def sms_phone_number
    @recipient.profile.phone.number
  end

  # -- commands/messages
  def add_message(sender:, body:, attachments:)
    # add message to list
    # TODO: does the discrepancy between this timestamp and the ultimate created_at
    # date matter?
    message = Message.new(
      sender: sender,
      body: body,
      timestamp: Time.zone.now.to_i,
      attachments: attachments,
      chat_id: @id.val,
    )

    @new_message = message
    @messages << message
    @events.add(Events::DidAddMessage.from_entity(self))
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
