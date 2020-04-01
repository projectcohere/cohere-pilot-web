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
  prop(:assignments, default: nil)
  prop(:is_referrer, default: false)
  prop(:is_referred, default: false)
  prop(:has_new_activity, default: false)
  prop(:received_message_at, default: nil)
  prop(:created_at, default: nil)
  prop(:updated_at, default: nil)
  prop(:completed_at, default: nil)

  # -- props/temporary
  attr(:new_assignment)
  attr(:selected_assignment)
  attr(:new_documents)
  attr(:selected_document)

  # -- factory --
  def self.open(recipient_profile:, enroller:, supplier_user:, supplier_account:)
    kase = Case.new(
      status: Status::Opened,
      program: Program::Name::Meap,
      recipient: Recipient.new(profile: recipient_profile),
      enroller_id: enroller.id,
      supplier_id: supplier_user.role.partner_id,
      supplier_account: supplier_account,
      has_new_activity: true,
    )

    kase.events.add(Events::DidOpen.from_entity(kase))
    kase.assign_user(supplier_user)

    kase
  end

  # -- commands --
  def add_dhs_data(dhs_account)
    @recipient.add_dhs_data(dhs_account)

    if @status == Status::Opened
      @status = Status::Pending
      events.add(Events::DidBecomePending.from_entity(self))
    end

    track_new_activity(true)
  end

  def add_cohere_data(supplier_account, profile, dhs_account)
    @supplier_account = supplier_account
    @recipient.add_cohere_data(profile, dhs_account)

    track_new_activity(false)
  end

  def add_admin_data(status)
    if status != @status
      @status = status
      @completed_at = complete? ? Time.zone.now : nil
    end
  end

  def remove_from_pilot
    @completed_at = Time.zone.now
    @status = Status::Removed
    @events.add(Events::DidComplete.from_entity(self))

    track_new_activity(false)
  end

  def submit_to_enroller
    if not can_submit?
      return
    end

    @status = Status::Submitted
    @events.add(Events::DidSubmit.from_entity(self))

    track_new_activity(false)
  end

  def complete(status)
    if not can_complete?
      return
    end

    @completed_at = Time.zone.now
    @status = status
    @events.add(Events::DidComplete.from_entity(self))

    track_new_activity(false)
  end

  def make_referral_to_program(program, supplier_id: nil)
    if not can_make_referral?(program)
      return nil
    end

    # mark as referrer
    @is_referrer = true
    @events.add(Events::DidMakeReferral.from_entity(self,
      program: program
    ))

    # create referred case
    referred = Case.new(
      program: program,
      status: Status::Opened,
      recipient: recipient,
      enroller_id: enroller_id,
      supplier_id: supplier_id,
      supplier_account: nil,
      documents: new_documents,
      is_referred: true,
      has_new_activity: true,
    )

    documents&.each do |d|
      if d.classification != :contract
        referred.copy_document(d)
      end
    end

    referred.events.add(
      Events::DidOpen.from_entity(referred)
    )

    # produce referral
    Referral.new(
      referrer: self,
      referred: referred
    )
  end

  # -- commands/assignments
  def assign_user(user)
    @assignments ||= []

    has_assignment = @assignments.any? do |a|
      a.partner_id == user.role.partner_id
    end

    if has_assignment
      return
    end

    @new_assignment = Assignment.new(
      user_id: user.id,
      user_email: user.email,
      partner_id: user.role.partner_id,
      partner_membership: user.role.name,
    )

    @assignments.push(@new_assignment)

    @events.add(Events::DidAssignUser.from_entity(self))
  end

  def select_assignment(partner_id)
    @selected_assignment = @assignments&.find do |a|
      a.partner_id == partner_id
    end
  end

  def destroy_selected_assignment
    @assignments.delete(@selected_assignment)
    @events.add(Events::DidUnassignUser.from_entity(self))
  end

  # -- commands/messages
  def add_chat_message(message)
    track_new_activity(false)
  end

  def add_mms_message(message)
    # add attachments as documents
    message.attachments&.each do |attachment|
      new_document = Document.download(attachment.url)
      add_document(new_document)
      @events.add(Events::DidAddMessageAttachment.from_entity(self, new_document))
    end

    # track recipient message receipt
    is_first = @received_message_at == nil
    @received_message_at = Time.zone.now
    @events.add(Events::DidReceiveMessage.from_entity(self, is_first: is_first))

    # track activity
    track_new_activity(true)
  end

  # -- commands/documents
  def sign_contract(program_contract)
    if not contract_document.nil?
      return
    end

    if program_contract.program != program
      return
    end

    new_document = Document.sign_contract(program_contract)
    add_document(new_document)
    @events.add(Events::DidSignContract.from_entity(self, new_document))
  end

  def copy_document(document)
    add_document(Document.copy(document))
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

  # -- commands/activity
  private def track_new_activity(has_new_activity)
    if @has_new_activity == has_new_activity
      return
    elsif has_new_activity && complete?
      return
    end

    @has_new_activity = has_new_activity
    @events.add_unique(Events::DidChangeActivity.from_entity(self))
  end

  # -- queries --
  # -- queries/status
  alias :referrer? :is_referrer
  alias :referral? :is_referred

  def opened?
    return @status == Status::Opened
  end

  def pending?
    return @status == Status::Pending
  end

  def submitted?
    return @status == Status::Submitted
  end

  def approved?
    return @status == Status::Approved
  end

  def denied?
    return @status == Status::Denied
  end

  def removed?
    return @status == Status::Removed
  end

  def active?
    return opened? || pending? || submitted?
  end

  def complete?
    return !active?
  end

  def wrap?
    return @program == Program::Name::Wrap
  end

  alias :can_complete? :submitted?

  def can_submit?
    return opened? || pending?
  end

  def can_make_referral?(program)
    approved? &&
    @program != program &&
    !@is_referred &&
    !@is_referrer
  end

  # -- queries/documents
  def documents
    @documents || @new_documents
  end

  def contract_document
    documents&.find do |d|
      d.classification == :contract
    end
  end

  def contract_variant
    contract_document&.source_url&.to_sym
  end

  # -- queries/household
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

  # -- callbacks --
  def did_save(record)
    @id.set(record.id)
    @record = record
  end
end
