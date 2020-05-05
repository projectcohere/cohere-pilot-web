class Chat < Entity
  prop(:record, default: nil)
  prop(:events, default: ListQueue::Empty)

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
      files: macro.file == nil ? [] : [macro.file],
      status: Message::Status::Queued,
    )

    return chat
  end

  # -- messages --
  # -- messages/commands
  def add_message(sender:, body:, files:, status:, remote_id: nil)
    timestamp = Time.zone.now.to_i

    attachments = files.map do |f|
      Attachment.from_source(f)
    end

    message = Message.new(
      sender: sender,
      body: body,
      timestamp: timestamp,
      status: status,
      attachments: attachments,
      remote_id: remote_id,
      chat_id: @id.val,
    )

    # update state
    @messages << message
    @new_message = message

    # add events
    if message.prepared?
      @events.add(Events::DidPrepareMessage.from_entity(message))
    end

    attachments.filter(&:remote?).each do |a|
      @events.add(Events::DidAddRemoteAttachment.from_entity(a))
    end
  end

  # -- messages/commands/selection
  def select_message(i)
    assert(i < @messages.count, "a message must exist to select it")
    @selected_message = @messages[i]
  end

  def attach_sms_to_message(sms)
    assert(@selected_message != nil, "a message must be selected")

    @selected_message.attach_sms(sms)

    new_status = Message::Status.from_key(sms.status)
    if new_status != nil
      change_message_status(new_status)
    end
  end

  def prepare_message
    assert(@selected_message != nil, "a message must be selected")

    if @selected_message.prepared?
      @events.add(Events::DidPrepareMessage.from_entity(@selected_message))
    end
  end

  def change_message_status(new_status)
    assert(@selected_message != nil, "a message must be selected")

    if @selected_message.change_status(new_status)
      @events.add(Events::DidChangeMessageStatus.from_entity(@selected_message))
    end
  end

  # -- attachments --
  # -- attachments/commands
  def upload_selected_attachment(file)
    assert(selected_attachment != nil, "an attachment must be selected")
    selected_attachment.upload(file)

    @events.add(Events::DidUploadAttachment.from_entity(self))
  end

  # -- attachments/queries
  def selected_attachment
    return selected_message&.selected_attachment
  end

  def selected_attachment_url
    return selected_attachment&.remote_url
  end

  # -- queries --
  def sms_phone_number
    @recipient.profile.phone.number
  end

  # -- callbacks --
  def did_save(record)
    @id.set(record.id)
    @record = record
  end
end
