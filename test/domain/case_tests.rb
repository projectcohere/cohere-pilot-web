require "test_helper"

class CaseTests < ActiveSupport::TestCase
  # -- creation --
  test "opens a case" do
    profile = Recipient::Profile.stub(
      phone: Recipient::Phone.stub(number: "1")
    )

    kase = Case.open(
      recipient_profile: profile,
      enroller: Partner.stub(id: 1),
      supplier_user: User.stub(id: 3, role: User::Role.stub(partner_id: 2)),
      supplier_account: :test_account,
    )

    assert(kase.has_new_activity)
    assert_equal(kase.recipient.profile, profile)
    assert_equal(kase.supplier_account, :test_account)
    assert_equal(kase.enroller_id, 1)
    assert_equal(kase.supplier_id, 2)
    assert_not_nil(kase.new_assignment)

    assert_instances_of(kase.events, [
      Case::Events::DidOpen,
      Case::Events::DidAssignUser,
    ])
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

  test "selects an assignment" do
    kase = Case.stub(
      assignments: [
        Case::Assignment.stub(partner_id: 3)
      ]
    )

    kase.select_assignment(3)
    assert_same(kase.selected_assignment, kase.assignments[0])
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

  test "adds the first text message from a recipient" do
    kase = Case.stub(
      status: Case::Status::Opened,
      recipient: stub_recipient_with_phone_number("1112223333"),
    )

    text_message = Mms::Message.stub(
      sender_phone_number: "1112223333",
    )

    kase.add_mms_message(text_message)
    assert_not_nil(kase.received_message_at)
    assert(kase.has_new_activity)

    assert_instances_of(kase.events, [
      Case::Events::DidReceiveMessage,
      Case::Events::DidChangeActivity,
    ])

    event = kase.events[0]
    assert(event.is_first)
  end

  test "adds a text message from a recipient and its attachments" do
    kase = Case.stub(
      status: Case::Status::Opened,
      recipient: stub_recipient_with_phone_number("1112223333"),
    )

    text_message = Mms::Message.stub(
      sender_phone_number: "1112223333",
      attachments: [
        Mms::Attachment.stub(url: "https://website.com/image.jpg")
      ],
    )

    kase.add_mms_message(text_message)
    assert(kase.has_new_activity)

    new_document = kase.new_documents[0]
    assert_length(kase.new_documents, 1)
    assert_equal(new_document.classification, :unknown)
    assert_equal(new_document.source_url, "https://website.com/image.jpg")

    assert_instances_of(kase.events, [
      Case::Events::DidUploadMessageAttachment,
      Case::Events::DidReceiveMessage,
      Case::Events::DidChangeActivity,
    ])
  end

  test "adds a text message from cohere" do
    kase = Case.stub(
      status: Case::Status::Opened,
      has_new_activity: true,
      recipient: stub_recipient_with_phone_number("1112223333"),
    )

    text_message = Mms::Message.stub(
      sender_phone_number: ENV["FRONT_API_PHONE_NUMBER"],
      receiver_phone_number: "1112223333",
      attachments: [
        Mms::Attachment.stub(url: "https://website.com/image.jpg")
      ],
    )

    kase.add_mms_message(text_message)
    assert_not(kase.has_new_activity)
    assert_blank(kase.new_documents)
    assert_instances_of(kase.events, [Case::Events::DidChangeActivity])
  end

  test "adds a chat message from a recipient and its attachments" do
    kase = Case.stub(
      status: Case::Status::Opened,
      has_new_activity: false,
    )

    chat_message = Chat::Message.stub(
      sender: Chat::Sender.recipient,
      attachments: %i[test_attachment],
    )

    kase.add_chat_message(chat_message)
    assert(kase.has_new_activity)

    new_document = kase.new_documents[0]
    assert_length(kase.new_documents, 1)
    assert_equal(new_document.classification, :unknown)
    assert_equal(new_document.new_file, :test_attachment)

    assert_instances_of(kase.events, [
      Case::Events::DidReceiveMessage,
      Case::Events::DidChangeActivity,
    ])
  end

  test "adds a chat message from cohere" do
    kase = Case.stub(
      has_new_activity: true,
    )

    chat_message = Chat::Message.stub(
      sender: Chat::Sender.automated,
      attachments: %i[test_attachment]
    )

    kase.add_chat_message(chat_message)
    assert_not(kase.has_new_activity)
    assert_blank(kase.new_documents)

    assert_instances_of(kase.events, [Case::Events::DidChangeActivity])
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
    assert_length(kase.new_documents, 1)

    new_contract = kase.new_documents[0]
    assert_equal(new_contract.classification, :contract)

    assert_instances_of(kase.events, [Case::Events::DidSignContract])
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

    kase.add_chat_message(Chat::Message.stub(
      sender: Chat::Sender.recipient,
    ))

    kase.add_chat_message(Chat::Message.stub(
      sender: Chat::Sender.automated,
    ))

    assert_instances_of(kase.events, [
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
