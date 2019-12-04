class Case < ::Entity
  # TODO: should these be generalized for entity/ar?
  prop(:record, default: nil)
  prop(:events, default: ArrayQueue::Empty)

  # -- props --
  prop(:id, default: Id::None)
  prop(:status)
  prop(:program)
  prop(:recipient)
  prop(:enroller_id)
  prop(:supplier_id)
  prop(:supplier_account)
  prop(:documents, default: nil)
  prop(:received_message_at, default: nil)
  prop(:updated_at, default: nil)
  prop(:completed_at, default: nil)
  props_end!

  # -- props/temporary
  attr(:new_documents)
  attr(:selected_document)

  # -- lifetime --
  def self.open(program:, profile:, enroller:, supplier:, supplier_account:)
    recipient = Recipient.new(
      profile: profile
    )

    kase = Case.new(
      status: Status::Opened,
      program: program,
      recipient: recipient,
      enroller_id: enroller.id,
      supplier_id: supplier.id,
      supplier_account: supplier_account
    )

    kase.events << Events::DidOpen.from_entity(kase)
    kase
  end

  # -- commands --
  def update_recipient_profile(profile)
    @recipient.update_profile(profile)
  end

  def update_supplier_account(account)
    @account = account
  end

  def attach_dhs_account(dhs_account)
    @recipient.attach_dhs_account(dhs_account)

    if @status == Status::Opened
      @status = Status::Pending
      events << Events::DidBecomePending.from_entity(self)
    end
  end

  def remove_from_pilot
    @completed_at = Time.zone.now
    @status = Status::Removed
    @events << Events::DidComplete.from_entity(self)
  end

  def submit_to_enroller
    if not can_submit?
      return
    end

    @status = Status::Submitted
    @events << Events::DidSubmit.from_entity(self)
  end

  def complete(status)
    if not can_complete?
      return
    end

    @completed_at = Time.zone.now
    @status = status
    @events << Events::DidComplete.from_entity(self)
  end

  # -- commands/messages
  def add_message(message)
    # track the message receipt
    @received_message_at = Time.zone.now
    @events << Events::DidReceiveMessage.from_entity(self)

    # upload message attachments
    message.attachments&.each do |attachment|
      new_document = Document.upload(attachment.url)
      add_document(new_document)
      @events << Events::DidUploadMessageAttachment.from_entity(self, new_document)
    end
  end

  # -- commands/documents
  def sign_contract
    if signed_contract?
      return
    end

    new_document = Document.sign_contract
    add_document(new_document)
    @events << Events::DidSignContract.from_entity(self, new_document)
  end

  private def add_document(document)
    @new_documents ||= []
    @new_documents << document
  end

  # -- commands/documents/selection
  def select_document(i)
    if i >= @documents.count
      raise "tried to select a document that didn't exist"
    end

    @selected_document = @documents[i]
  end

  def attach_file_to_selected_document(file)
    if @selected_document.nil?
      raise "tried to attach a file to the selected document, but there wasn't one"
    end

    @selected_document.attach_file(file)
  end

  # -- queries --
  def can_submit?
    @status == Status::Opened || @status == Status::Pending
  end

  def can_complete?
    @status == Status::Submitted
  end

  def can_be_referred?
    @status == Status::Approved
  end

  def fpl_percentage
    household = recipient&.dhs_account&.household
    if household.nil?
      return nil
    end

    hh_size = household.size
    hh_month_cents = household.income_cents

    if hh_size.nil? || hh_month_cents.nil?
      return nil
    end

    hh_year_cents = hh_month_cents * 12

    fpl_month_cents = 1580_00 + (hh_size - 1) * 540_00
    fpl_year_cents = fpl_month_cents * 8
    fpl_percentage = hh_year_cents * 100 / fpl_year_cents.to_f

    fpl_percentage.round(0)
  end

  def contract
    @documents&.find do |d|
      d.classification == :contract
    end
  end

  def signed_contract?
    not contract.nil?
  end

  # -- callbacks --
  def did_save(record)
    @id.set(record.id)
    @record = record
  end
end
