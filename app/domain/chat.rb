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
      files: macro.attachment == nil ? [] : [macro.attachment],
      status: Message::Status::Queued,
    )

    return chat
  end

  # -- messages --
  # -- messages/commands
  def add_message(sender:, body:, files:, status:, remote_id: nil)
    attachments = files.map do |f|
      Attachment.from_source(f)
    end

    message = Message.new(
      sender: sender,
      body: body,
      timestamp: Time.zone.now.to_i,
      status: status,
      attachments: attachments,
      chat_id: @id.val,
      remote_id: remote_id,
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

  def select_message(i)
    assert(i < @messages.count, "a message must exist to select it")
    @selected_message = @messages[i]
  end

  def prepare_selected_message
    assert(@selected_message != nil, "a message must be selected")

    if @selected_message.prepared?
      @events.add(Events::DidPrepareMessage.from_entity(@selected_message))
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
