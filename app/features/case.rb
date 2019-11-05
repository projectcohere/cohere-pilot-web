class Case < ::Entity
  # TODO: should this be generalized for the aggregate root?
  prop(:record, default: nil)

  # -- props --
  prop(:id, default: nil)
  prop(:status)
  prop(:recipient)
  prop(:enroller_id)
  prop(:supplier_id)
  prop(:account)
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
    if not (status == :opened || @status == :pending)
      return
    end

    status = :submitted
  end

  # -- events --
  def did_save(record)
    @record = record
    @id = record.id
  end

  # -- factories --
  def self.from_record(r)
    Case.new(
      record: r,
      id: r.id,
      recipient: Recipient.from_record(r.recipient),
      supplier: Supplier.from_record(r.supplier),
      enroller: Enroller.from_record(r.enroller),
      status: r.status.to_sym,
      updated_at: r.updated_at,
      completed_at: r.completed_at
    )
  end
end
