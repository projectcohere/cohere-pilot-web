class Case < ::Entity
  # TODO: should these be generalized for entity/ar?
  prop(:record, default: nil)
  prop(:events, default: [])

  # -- props --
  prop(:id, default: Id::None)
  prop(:status)
  prop(:recipient)
  prop(:account)
  prop(:enroller_id)
  prop(:supplier_id)
  prop(:updated_at, default: nil)
  prop(:completed_at, default: nil)
  props_end!

  # -- creation --
  def self.open(profile:, account:, enroller:, supplier:)
    recipient = Recipient.new(
      profile: profile
    )

    kase = Case.new(
      status: :opened,
      account: account,
      recipient: recipient,
      enroller_id: enroller.id,
      supplier_id: supplier.id
    )

    kase.events << Events::DidOpen.from_case(kase)
    kase
  end

  # -- commands --
  def update_supplier_account(account)
    @account = account
  end

  def update_recipient_profile(profile)
    @recipient.update_profile(profile)
  end

  def attach_dhs_account(dhs_account)
    if @status == :opened
      @status = :pending
    end

    @recipient.attach_dhs_account(dhs_account)
  end

  def submit
    if not (@status == :opened || @status == :pending)
      return
    end

    @status = :submitted
    @events << Events::DidSubmit.from_case(self)
  end

  # -- commands/factories
  def upload_documents_from_message(message)
    message.attachments.map do |attachment|
      Document.new(case_id: id, source_url: attachment.url)
    end
  end

  # -- events --
  def did_save(record)
    @id.set(record.id)
    @record = record
  end
end
