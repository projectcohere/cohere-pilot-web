class Case < ::Entity
  # TODO: should these be generalized for entity/ar?
  prop(:record, default: nil)
  prop(:events, default: ListQueue::Empty)

  # -- props --
  prop(:id, default: Id::None)
  prop(:status)
  prop(:condition, default: Condition::Active)
  prop(:program)
  prop(:recipient)
  prop(:enroller_id)
  prop(:benefit, default: nil)
  prop(:documents, default: nil)
  prop(:assignments, default: nil)
  prop(:notes, default: nil)
  prop(:new_activity, default: false, predicate: true)
  prop(:received_message_at, default: nil)
  prop(:created_at, default: nil)
  prop(:updated_at, default: nil)
  prop(:completed_at, default: nil)

  # TODO: these, and a few other fields, are only relevant to specific
  # programs. hmw model this in a way that is more composable and
  # flexible?
  prop(:food, default: nil)
  # TODO: rename to utility account?
  prop(:supplier_account, default: nil)

  # -- props/temporary
  attr(:new_assignment)
  attr(:selected_assignment)
  attr(:selected_note)
  attr(:new_documents)
  attr(:selected_document)

  # -- factory --
  def self.open(temp_id: nil, program:, profile:, household:, enroller:, supplier_account:, food:)
    household ||= ::Recipient::Household.new(
      proof_of_income: ::Recipient::ProofOfIncome::Dhs,
    )

    recipient = Recipient.new(
      profile: profile,
      household: household,
    )

    kase = Case.new(
      status: Status::Opened,
      program: program,
      recipient: recipient,
      enroller_id: enroller.id,
      supplier_account: supplier_account,
      food: food,
      new_activity: true,
    )

    kase.events.add(
      Events::DidOpen.from_entity(kase, temp_id: temp_id)
    )

    return kase
  end

  # -- commands --
  def add_governor_data(household)
    @recipient.add_governor_data(household)
    track_new_activity(true)
  end

  def add_agent_data(profile, household, supplier_account, food, benefit)
    @recipient.add_agent_data(profile, household)
    @supplier_account = supplier_account
    @food = food
    @benefit = benefit
    track_new_activity(false)
  end

  def add_admin_data(status)
    if @status == status
      return
    end

    @status = status

    if complete?
      @completed_at = Time.zone.now
    else
      @condition = Condition::Active
      @completed_at = nil
    end
  end

  def remove
    @status = Status::Removed
    @condition = Condition::Archived
    @completed_at = Time.zone.now

    @events.add(Events::DidComplete.from_entity(self))

    track_new_activity(false)
  end

  def convert_to_program(program)
    @program = program
  end

  def submit_to_enroller
    if not (opened? || returned?)
      return
    end

    @status = Status::Submitted
    remove_assignment(Role::Enroller)
    @events.add(Events::DidSubmitToEnroller.from_entity(self))

    track_new_activity(false)
  end

  def return_to_agent
    if not submitted?
      return
    end

    @status = Status::Returned
    remove_assignment(Role::Agent)
    @events.add(Events::DidReturnToAgent.from_entity(self))

    track_new_activity(true)
  end

  def complete(status, benefit_amount)
    if not submitted?
      return
    end

    @status = status
    @completed_at = Time.zone.now
    @benefit = benefit_amount

    remove_assignment(Role::Agent)
    @events.add(Events::DidComplete.from_entity(self))

    track_new_activity(true)
  end

  def delete
    @condition = Condition::Deleted
  end

  def archive
    @condition = Condition::Archived
  end

  # -- commands/referral
  def make_referral(program)
    if not approved?
      return
    end

    # mark as referrer
    @referrer = true
    @condition = Condition::Archived
    @events.add(Events::DidMakeReferral.from_entity(self,
      program: program
    ))

    # create referred case
    referred = Case.new(
      program: program,
      status: Status::Opened,
      recipient: recipient,
      enroller_id: enroller_id,
      documents: new_documents,
      new_activity: true,
    )

    documents&.each do |d|
      if d.classification != :contract
        referred.copy_document(d)
      end
    end

    referred.events.add(
      Events::DidOpen.from_entity(referred, temp_id: nil)
    )

    # produce referral
    return Referral.new(
      referrer: self,
      referred: referred
    )
  end

  # -- commands/assignments
  def assign_user(user)
    @assignments ||= []

    assigned = @assignments.any? do |a|
      a.role == user.role && a.partner_id == user.partner_id
    end

    if assigned
      return
    end

    @new_assignment = Assignment.new(
      role: user.role,
      user_id: user.id,
      user_email: user.email,
      partner_id: user.partner_id,
    )

    @assignments.push(@new_assignment)

    @events.add(Events::DidAssignUser.from_entity(self))
  end

  def select_assignment(partner_id)
    @selected_assignment = @assignments&.find do |a|
      a.partner_id == partner_id
    end
  end

  def remove_selected_assignment
    if @selected_assignment == nil
      return
    end

    @selected_assignment.remove
    @assignments.delete(@selected_assignment)
    @events.add(Events::DidUnassignUser.from_entity(self))
  end

  private def remove_assignment(role)
    @selected_assignment = @assignments&.find { |a| a.role == role }
    remove_selected_assignment
  end

  # -- commands/notes
  def add_note(body, user)
    @notes ||= []

    @selected_note = Note.new(
      body: body,
      user_id: user.id,
      user_email: user.email,
    )

    @notes.push(@selected_note)
  end

  # -- commands/messages
  def add_chat_message(message)
    if message.sent_by_recipient?
      # add attachments as documents
      message.attachments&.each do |attachment|
        new_document = Document.attach_file(attachment.file)
        add_document(new_document)
      end

      # track recipient message receipt
      is_first = @received_message_at == nil
      @received_message_at = Time.zone.now
      @events.add(Events::DidReceiveMessage.from_entity(self, is_first: is_first))
    end

    # track activity
    track_new_activity(message.sent_by_recipient?)
  end

  # -- commands/documents
  def sign_contract(program_contract)
    if not contract_document.nil?
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
  private def track_new_activity(new_activity)
    if @new_activity == new_activity
      return
    elsif new_activity && archived?
      return
    end

    @new_activity = new_activity
    @events.add_unique(Events::DidChangeActivity.from_entity(self))
  end

  # -- queries --
  # -- queries/status
  delegate(
    :opened?,
    :submitted?,
    :returned?,
    :approved?,
    :denied?,
    :removed?,
    :complete?,
    to: :status,
  )

  # -- queries/condition
  delegate(
    :active?,
    :archived?,
    :deleted?,
    to: :condition,
  )

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

  # -- callbacks --
  def did_save(record)
    @id.set(record.id)
    @record = record
  end

  def did_save_assignment(record)
    @new_assignment.did_save(record)
  end
end
