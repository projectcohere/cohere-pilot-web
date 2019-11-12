class Case < ::Entity
  # TODO: should these be generalized for entity/ar?
  prop(:record, default: nil)
  prop(:events, default: EventQueue::Empty)

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

  # TODO: rename to `submit_to_enroller`
  def submit
    case @status
    when :opened, :pending
      @status = :submitted
      @events << Events::DidSubmit.from_case(self)
    end
  end

  # -- commands/factories
  def upload_documents_from_message(message)
    message.attachments.map do |attachment|
      Document.upload(attachment.url, case_id: id)
    end
  end

  def sign_contract
    Document.generate_contract(case_id: id)
  end

  # -- queries --
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

    fpl_percentage.round(2)
  end

  # -- callbacks --
  def did_save(record)
    @id.set(record.id)
    @record = record
  end
end
