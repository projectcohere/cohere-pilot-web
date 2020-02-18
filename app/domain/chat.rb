class Chat < Entity
  prop(:record, default: nil)
  prop(:events, default: ArrayQueue::Empty)

  # -- props --
  prop(:id, default: Id::None)
  prop(:recipient)
  prop(:session, default: nil)
  prop(:messages, default: [])
  prop(:notification, default: nil)
  prop(:sms_conversation_id, default: nil)
  props_end!

  # -- props/temporary
  attr(:new_message)
  attr(:selected_message)

  # -- factories --
  def self.open(recipient_id, macro_repo: Macro::Repo.get)
    chat = Chat.new(
      recipient: Recipient.new(
        id: recipient_id,
        profile: nil, # TODO: what about our domain results in incomplete data here?
      ),
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

  # -- commands --
  def start_session
    @session = SecureRandom.base58
  end

  # -- commands/messages
  def add_message(sender:, body:, attachments:)
    # add message to list
    message = Message.new(
      sender: sender,
      body: body,
      attachments: attachments,
      chat_id: @id.val,
    )

    @new_message = message
    @messages << message
    @events << Events::DidAddMessage.from_entity(self)

    # set notification based on sender
    if sender != Sender::Recipient
      @notification = Notification.new
    else
      @notification = nil
    end
  end

  def select_message(i)
    if i >= @messages.count
      raise "can't select a message that does not exist"
    end

    @selected_message = @messages[i]
  end

  # -- commands/notifcations
  def send_sms_notification
    if not block_given?
      raise "can't send notification without a service to invoke"
    elsif @notification == nil
      raise "can't send notification if there is not one to send"
    end

    sms_conversation_id = yield
    if sms_conversation_id != nil
      @sms_conversation_id = sms_conversation_id
    end

    @notification = nil
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
