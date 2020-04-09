require "test_helper"

class CaseTests < ActiveSupport::TestCase
  # -- creation --
  test "opens a case for the supplier's primary program" do
    profile = Recipient::Profile.stub(
      phone: Recipient::Phone.stub(number: "1")
    )

    kase = Case.open(
      recipient_profile: profile,
      enroller: Partner.stub(id: 1),
      supplier: Partner.stub(id: 2, programs: [Program::Name::Wrap]),
      supplier_account: :test_account,
    )

    assert(kase.has_new_activity)
    assert_equal(kase.program, Program::Name::Wrap)
    assert_equal(kase.recipient.profile, profile)
    assert_equal(kase.supplier_account, :test_account)
    assert_equal(kase.enroller_id, 1)
    assert_equal(kase.supplier_id, 2)

    assert_instances_of(kase.events, [Case::Events::DidOpen])
  end

  # -- commands --
  test "adds cohere data" do
    kase = Case.stub(
      recipient: Case::Recipient.stub,
      has_new_activity: true,
    )

    kase.add_cohere_data(
      Case::Account.stub,
      Recipient::Profile.stub,
      Recipient::DhsAccount.stub,
    )

    assert_not_nil(kase.supplier_account)
    assert_not_nil(kase.recipient.profile)
    assert_not_nil(kase.recipient.dhs_account)
    assert_not(kase.has_new_activity)
  end

  test "adds dhs data" do
    kase = Case.stub(
      status: Case::Status::Opened,
      recipient: Case::Recipient.stub,
    )

    kase.add_dhs_data(:test_account)
    assert(kase.has_new_activity)
    assert_equal(kase.recipient.dhs_account, :test_account)
    assert_equal(kase.status, Case::Status::Pending)

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
    assert_equal(kase.status, Case::Status::Approved)
    assert_not_nil(kase.completed_at)
  end

  test "submits a pending case to an enroller" do
    kase = Case.stub(
      status: Case::Status::Pending,
      recipient: Case::Recipient.stub,
      has_new_activity: true,
    )

    kase.submit_to_enroller
    assert_not(kase.has_new_activity)
    assert_equal(kase.status, Case::Status::Submitted)

    assert_instances_of(kase.events, [
      Case::Events::DidSubmit,
      Case::Events::DidChangeActivity,
    ])
  end

  test "completes a submitted case" do
    kase = Case.stub(
      status: Case::Status::Submitted,
      has_new_activity: true,
    )

    kase.complete(Case::Status::Approved)
    assert_not(kase.has_new_activity)
    assert_equal(kase.status, Case::Status::Approved)
    assert_in_delta(Time.zone.now, kase.completed_at, 1.0)

    assert_instances_of(kase.events, [
      Case::Events::DidComplete,
      Case::Events::DidChangeActivity,
    ])
  end

  test "removes a case from the pilot" do
    kase = Case.stub(
      status: Case::Status::Pending,
      has_new_activity: true,
    )

    kase.remove_from_pilot
    assert_not(kase.has_new_activity)
    assert_equal(kase.status, Case::Status::Removed)
    assert_in_delta(Time.zone.now, kase.completed_at, 1.0)

    assert_instances_of(kase.events, [
      Case::Events::DidComplete,
      Case::Events::DidChangeActivity,
    ])
  end

  test "makes a referral to a new program" do
    kase = Case.stub(
      status: Case::Status::Approved,
      program: Program::Name::Meap,
      documents: [
        Document.stub(
          classification: :unknown
        )
      ],
      recipient: Case::Recipient.stub(
        id: 3,
        profile: Recipient::Profile.stub(
          phone: Recipient::Phone.stub(number: "1")
        )
      ),
    )

    referral = kase.make_referral_to_program(Program::Name::Wrap)
    assert_not_nil(referral)

    referrer = referral.referrer
    assert(referral.referrer.referrer?)

    referred = referral.referred
    assert(referred.referral?)
    assert(referred.has_new_activity)
    assert_equal(referred.program, Program::Name::Wrap)

    new_documents = referred.new_documents
    assert_length(new_documents, referrer.documents.length)

    event = referrer.events[0]
    assert_instances_of(referrer.events, [Case::Events::DidMakeReferral])
    assert_equal(event.case_program, Program::Name::Wrap)

    event = referred.events[0]
    assert_instances_of(referred.events, [Case::Events::DidOpen])
    assert(event.case_is_referred)
  end

  test "does not make a referral to the same program" do
    kase = Case.stub(
      status: Case::Status::Approved,
      program: Program::Name::Meap,
      is_referrer: false
    )

    referral = kase.make_referral_to_program(Program::Name::Meap)
    assert_nil(referral)
  end

  test "does not make a second referral" do
    kase = Case.stub(
      status: Case::Status::Approved,
      program: Program::Name::Meap,
      is_referrer: true
    )

    referral = kase.make_referral_to_program(Program::Name::Wrap)
    assert_nil(referral)

    kase = Case.stub(
      status: Case::Status::Approved,
      program: Program::Name::Wrap,
      is_referred: true
    )

    referral = kase.make_referral_to_program(Program::Name::Meap)
    assert_nil(referral)
  end

  # -- commands/assignments
  test "doesn't assign a user if an assignment for that partner exists" do
    kase = Case.stub(
      assignments: [
        Case::Assignment.stub(partner_id: 3)
      ]
    )

    user = User.stub(
      id: Id.new(3),
      role: User::Role.stub(partner_id: 3),
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
      role: User::Role.stub(
        name: :cohere,
        partner_id: 5,
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

    kase.destroy_selected_assignment
    assert_empty(kase.assignments)
    assert_instances_of(kase.events, [Case::Events::DidUnassignUser])
  end

  # -- commands/messages
  def stub_recipient_with_phone_number(phone_number)
    return Case::Recipient.stub(
      profile: Recipient::Profile.stub(
        phone: Recipient::Phone.stub(
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
    assert(kase.has_new_activity)
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
    assert(kase.has_new_activity)

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

  test "adds a cohere message" do
    kase = Case.stub(
      status: Case::Status::Opened,
      has_new_activity: true,
    )

    message = Chat::Message.stub(
      sender: Chat::Sender.automated
    )

    kase.add_chat_message(message)
    assert_not(kase.has_new_activity)

    events = kase.events
    assert_instances_of(events, [Case::Events::DidChangeActivity])
  end

  test "signs a contract" do
    kase = Case.stub(
      program: Program::Name::Wrap
    )

    contract = Program::Contract.new(
      program: Program::Name::Wrap,
      variant: Program::Contract::Wrap3h
    )

    kase.sign_contract(contract)

    documents = kase.new_documents
    assert_length(documents, 1)
    assert_equal(documents[0].classification, :contract)

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

  test "doesn't sign a contract for the wrong program" do
    kase = Case.stub(
      program: Program::Name::Meap
    )

    contract = Program::Contract.new(
      program: Program::Name::Wrap,
      variant: Program::Contract::Wrap1k
    )

    kase.sign_contract(contract)
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
      has_new_activity: false,
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
    assert_not(event.case_has_new_activity)
  end

  # -- queries --
  test "has an fpl percentage with a household" do
    household = Recipient::Household.stub(
      size: 5,
      income_cents: 2493_33
    )

    kase = Case.stub(
      recipient: Case::Recipient.stub(
        dhs_account: Recipient::DhsAccount.stub(
          household: household
        )
      )
    )

    assert_equal(kase.fpl_percentage, 100)
  end

  test "has no fpl percentage without a household" do
    kase = Case.stub
    assert_nil(kase.fpl_percentage)
  end

  test "has no fpl percentage with an incomplete household" do
    household = Recipient::Household.stub(
      size: nil,
      income_cents: 2493_33
    )

    kase = Case.stub(
      recipient: Case::Recipient.stub(
        dhs_account: Recipient::DhsAccount.stub(
          household: household
        )
      )
    )

    assert_nil(kase.fpl_percentage)
  end

  test "has a contract document" do
    kase = Case.stub(
      documents: [Document.stub(classification: :contract)]
    )

    assert_not_nil(kase.contract_document)
  end
end
