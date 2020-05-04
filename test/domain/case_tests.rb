require "test_helper"

class CaseTests < ActiveSupport::TestCase
  # -- creation --
  test "opens a case" do
    profile = Recipient::Profile.stub(
      phone: Phone.stub(number: "1")
    )

    kase = Case.open(
      program: :test_program,
      profile: profile,
      household: :test_household,
      enroller: Partner.stub(id: 1),
      supplier_account: :test_account,
    )

    assert(kase.new_activity?)
    assert(kase.opened?)
    assert(kase.active?)
    assert_equal(kase.program, :test_program)
    assert_equal(kase.recipient.profile, profile)
    assert_equal(kase.recipient.household, :test_household)
    assert_equal(kase.supplier_account, :test_account)
    assert_equal(kase.enroller_id, 1)

    assert_instances_of(kase.events, [Case::Events::DidOpen])
  end

  test "opens a case with no household info" do
    profile = Recipient::Profile.stub(
      phone: Phone.stub(number: "1")
    )

    kase = Case.open(
      program: :test_program,
      profile: profile,
      household: nil,
      enroller: Partner.stub(id: 1),
      supplier_account: :test_account,
    )

    assert(kase.recipient.household.proof_of_income.dhs?)
    assert_instances_of(kase.events, [Case::Events::DidOpen])
  end

  # -- commands --
  test "adds agent data" do
    kase = Case.stub(
      recipient: Case::Recipient.stub,
      new_activity: true,
    )

    kase.add_agent_data(
      Case::Account.stub,
      Recipient::Profile.stub,
      Recipient::Household.stub,
    )

    assert_not_nil(kase.supplier_account)
    assert_not_nil(kase.recipient.profile)
    assert_not_nil(kase.recipient.household)
    assert_not(kase.new_activity?)
  end

  test "adds governor data" do
    kase = Case.stub(
      status: Case::Status::Opened,
      recipient: Case::Recipient.stub,
    )

    kase.add_governor_data(:test_household)
    assert(kase.new_activity?)
    assert(kase.pending?)
    assert_equal(kase.recipient.household, :test_household)

    assert_instances_of(kase.events, [
      Case::Events::DidBecomePending,
      Case::Events::DidChangeActivity,
    ])
  end

  test "adds admin data" do
    kase = Case.stub(
      recipient: Case::Recipient.stub,
    )

    kase.add_admin_data(Case::Status::Approved)
    assert(kase.approved?)
    assert_not_nil(kase.completed_at)
  end

  test "submits a pending case to an enroller" do
    kase = Case.stub(
      status: Case::Status::Pending,
      recipient: Case::Recipient.stub,
      new_activity: true,
    )

    kase.submit_to_enroller
    assert(kase.submitted?)
    assert_not(kase.new_activity?)

    assert_instances_of(kase.events, [
      Case::Events::DidSubmit,
      Case::Events::DidChangeActivity,
    ])
  end

  test "completes a submitted case" do
    kase = Case.stub(
      status: Case::Status::Submitted,
      new_activity: true,
      assignments: [
        Case::Assignment.stub(role: Role::Agent),
      ],
    )

    kase.complete(Case::Status::Approved)
    assert(kase.approved?)
    assert_not(kase.new_activity?)
    assert_in_delta(Time.zone.now, kase.completed_at, 1.0)

    assignments = kase.assignments
    assert_empty(assignments)
    assert(kase.selected_assignment&.removed?)

    assert_instances_of(kase.events, [
      Case::Events::DidUnassignUser,
      Case::Events::DidComplete,
      Case::Events::DidChangeActivity,
    ])
  end

  test "removes a case from the pilot" do
    kase = Case.stub(
      status: Case::Status::Pending,
      new_activity: true,
    )

    kase.remove_from_pilot
    assert(kase.removed?)
    assert(kase.archived?)
    assert_not(kase.new_activity?)
    assert_in_delta(Time.zone.now, kase.completed_at, 1.0)

    assert_instances_of(kase.events, [
      Case::Events::DidComplete,
      Case::Events::DidChangeActivity,
    ])
  end

  test "makes a referral to a new program" do
    kase = Case.stub(
      status: Case::Status::Approved,
      documents: [
        Document.stub(
          classification: :unknown
        )
      ],
      recipient: Case::Recipient.stub(
        id: 3,
        profile: Recipient::Profile.stub(
          phone: Phone.stub(number: "1")
        )
      ),
    )

    program = Program.stub(id: 1)

    referral = kase.make_referral(program)
    assert_not_nil(referral)

    referrer = referral.referrer
    assert(referrer.referrer?)
    assert(referrer.archived?)

    referred = referral.referred
    assert(referred.referred?)
    assert(referred.new_activity?)
    assert(referred.opened?)
    assert(referred.active?)
    assert_equal(referred.program, program)

    new_documents = referred.new_documents
    assert_length(new_documents, referrer.documents.length)

    event = referrer.events[0]
    assert_instances_of(referrer.events, [Case::Events::DidMakeReferral])
    assert_equal(event.case_program, program)

    event = referred.events[0]
    assert_instances_of(referred.events, [Case::Events::DidOpen])
    assert(event.case_is_referred)
  end

  test "deletes a case" do
    kase = Case.stub
    kase.delete
    assert(kase.deleted?)
  end

  # -- commands/assignments
  test "doesn't assign a user if an assignment for that partner exists" do
    kase = Case.stub(
      assignments: [
        Case::Assignment.stub(
          role: Role::Agent,
          partner_id: 3
        )
      ]
    )

    user = User.stub(
      id: Id.new(3),
      role: Role::Agent,
      partner: Partner.stub(id: 3),
    )

    kase.assign_user(user)
    assert_nil(kase.new_assignment)
    assert_empty(kase.events)
  end

  test "assigns a user" do
    kase = Case.stub
    user = User.stub(
      id: Id.new(3),
      email: :test_email,
      role: Role::Agent,
      partner: Partner.stub(
        id: 5,
        membership: Partner::Membership::Cohere,
      ),
    )

    kase.assign_user(user)

    assignment = kase.new_assignment
    assert_not_nil(assignment)
    assert_equal(kase.assignments, [assignment])
    assert_equal(assignment.user_id.val, 3)
    assert_equal(assignment.user_email, :test_email)
    assert_equal(assignment.partner_id, 5)
    assert_instances_of(kase.events, [Case::Events::DidAssignUser])
  end

  test "selects an assignment" do
    kase = Case.stub(
      assignments: [
        Case::Assignment.stub(partner_id: 3)
      ]
    )

    kase.select_assignment(3)
    assert_same(kase.selected_assignment, kase.assignments[0])
  end

  test "destroys a selected assignment" do
    kase = Case.stub(
      assignments: [
        Case::Assignment.stub(partner_id: 3)
      ]
    )

    kase.select_assignment(3)

    kase.remove_selected_assignment
    assert_empty(kase.assignments)
    assert_instances_of(kase.events, [Case::Events::DidUnassignUser])
  end

  # -- commands/messages
  def stub_recipient_with_phone_number(phone_number)
    return Case::Recipient.stub(
      profile: Recipient::Profile.stub(
        phone: Phone.stub(
          number: phone_number,
        ),
      ),
    )
  end

  test "adds the first recipient message" do
    kase = Case.stub(
      status: Case::Status::Opened,
    )

    message = Chat::Message.stub(
      sender: Chat::Sender.recipient,
    )

    kase.add_chat_message(message)
    assert(kase.new_activity?)
    assert_not_nil(kase.received_message_at)

    events = kase.events
    assert_instances_of(events, [
      Case::Events::DidReceiveMessage,
      Case::Events::DidChangeActivity,
    ])

    event = kase.events[0]
    assert(event.is_first)
  end

  test "adds a recipient message with attachments" do
    kase = Case.stub(
      status: Case::Status::Opened,
      received_message_at: Time.now,
    )

    message = Chat::Message.stub(
      sender: Chat::Sender.recipient,
      attachments: [Chat::Attachment.stub(file: :test_file)]
    )

    kase.add_chat_message(message)
    assert(kase.new_activity?)

    documents = kase.new_documents
    assert_length(documents, 1)

    document = documents[0]
    assert_equal(document.new_file, :test_file)
    assert_equal(document.classification, :unknown)

    events = kase.events
    assert_instances_of(events, [
      Case::Events::DidReceiveMessage,
      Case::Events::DidChangeActivity,
    ])

    event = kase.events[0]
    assert_not(event.is_first)
  end

  test "adds an agent message" do
    kase = Case.stub(
      status: Case::Status::Opened,
      new_activity: true,
    )

    message = Chat::Message.stub(
      sender: Chat::Sender.automated
    )

    kase.add_chat_message(message)
    assert_not(kase.new_activity?)

    events = kase.events
    assert_instances_of(events, [Case::Events::DidChangeActivity])
  end

  test "signs a contract" do
    kase = Case.stub
    contract = Program::Contract.stub

    kase.sign_contract(contract)

    document = kase.new_documents[0]
    assert_length(kase.new_documents, 1)
    assert_equal(document.classification, :contract)

    events = kase.events
    assert_instances_of(events, [Case::Events::DidSignContract])
  end

  test "doesn't sign a contract when one already exists" do
    kase = Case.stub(
      documents: [
        Document.stub(classification: :contract)
      ]
    )

    kase.sign_contract(nil)
    assert_nil(kase.new_documents)
    assert_empty(kase.events)
  end

  # -- commands/documents/selection
  test "selects a document" do
    kase = Case.stub(documents: [Document.stub])

    kase.select_document(0)
    assert_equal(kase.selected_document, kase.documents[0])
  end

  test "doesn't select a missing document" do
    kase = Case.stub

    assert_raises do
      kase.select_document(0)
    end
  end

  test "attaches files to the selected document" do
    kase = Case.stub(documents: [Document.stub])
    kase.select_document(0)

    kase.attach_file_to_selected_document("test-file")
    assert_equal(kase.selected_document.new_file, "test-file")
  end

  test "doesn't attach files to a missing document" do
    kase = Case.stub(documents: [Document.stub])

    assert_raises do
      kase.attach_file_to_selected_document("test-file")
    end
  end

  # -- commands/activity
  test "doesn't add redundant activity events" do
    kase = Case.stub(
      status: Case::Status::Opened,
      new_activity: false,
    )

    s = Chat::Sender
    kase.add_chat_message(Chat::Message.stub(sender: s.recipient))
    kase.add_chat_message(Chat::Message.stub(sender: s.automated))

    events = kase.events
    assert_instances_of(events, [
      Case::Events::DidReceiveMessage,
      Case::Events::DidChangeActivity,
    ])

    event = kase.events[1]
    assert_not(event.case_new_activity?)
  end

  # -- queries --
  test "has a contract document" do
    kase = Case.stub(
      documents: [Document.stub(classification: :contract)]
    )

    assert_not_nil(kase.contract_document)
  end
end
