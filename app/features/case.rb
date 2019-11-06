class Case < ::Entity
  # TODO: should this be generalized for the aggregate root?
  prop(:record, default: nil)

  # -- props --
  prop(:id, default: nil)
  prop(:status)
  prop(:recipient)
  prop(:account)
  prop(:enroller_id)
  prop(:supplier_id)
  prop(:updated_at, default: nil)
  prop(:completed_at, default: nil)

  # -- lifetime --
  define_initialize!

  # -- creation --
  def self.open(profile:, account:, enroller:, supplier:)
    Case.new(
      status: :opened,
      account: account,
      recipient: Recipient.new(
        profile: profile
      ),
      enroller_id: enroller.id,
      supplier_id: supplier.id,
    )
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
  end

  # -- commands/factories
  def upload_documents_from_message(message)
    message.attachments.map do |attachment|
      Document.new(case_id: id, source_url: attachment.url)
    end
  end

  # -- events --
  def did_save(record)
    @record = record
    @id = record.id
  end
end
