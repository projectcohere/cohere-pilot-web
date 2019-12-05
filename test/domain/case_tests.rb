require "test_helper"

class CaseTests < ActiveSupport::TestCase
  # -- creation --
  test "opens the case" do
    kase = Case.open(
      program: Program::Meap,
      profile: :test_profile,
      enroller: Enroller.stub(id: 1),
      supplier: Supplier.stub(id: 2),
      supplier_account: :test_account
    )

    assert_equal(kase.recipient.profile, :test_profile)
    assert_equal(kase.supplier_account, :test_account)
    assert_equal(kase.enroller_id, 1)
    assert_equal(kase.supplier_id, 2)

    assert_length(kase.events, 1)
    assert_instance_of(Case::Events::DidOpen, kase.events[0])
  end

  # -- commands --
  test "becomes pending with the dhs account" do
    kase = Case.stub(
      status: Case::Status::Opened,
      recipient: Recipient.stub,
    )

    kase.attach_dhs_account(:test_account)
    assert_equal(kase.recipient.dhs_account, :test_account)
    assert_equal(kase.status, Case::Status::Pending)

    assert_length(kase.events, 1)
    assert_instance_of(Case::Events::DidBecomePending, kase.events[0])
  end

  test "doesn't revert back to pending after submission" do
    kase = Case.stub(
      status: Case::Status::Submitted,
      recipient: Recipient.stub
    )

    kase.attach_dhs_account(:test_account)
    assert_equal(kase.status, Case::Status::Submitted)
  end

  test "submits a pending case to an enroller" do
    kase = Case.stub(
      status: Case::Status::Pending,
      recipient: Recipient.stub
    )

    kase.submit_to_enroller
    assert_equal(kase.status, Case::Status::Submitted)

    assert_length(kase.events, 1)
    assert_instance_of(Case::Events::DidSubmit, kase.events[0])
  end

  test "completes a submitted case" do
    kase = Case.stub(
      status: Case::Status::Submitted
    )

    kase.complete(Case::Status::Approved)
    assert_equal(kase.status, Case::Status::Approved)
    assert_in_delta(Time.zone.now, kase.completed_at, 1.0)

    assert_length(kase.events, 1)
    assert_instance_of(Case::Events::DidComplete, kase.events[0])
  end

  test "removes a case from the pilot" do
    kase = Case.stub(
      status: Case::Status::Pending
    )

    kase.remove_from_pilot
    assert_equal(kase.status, Case::Status::Removed)
    assert_in_delta(Time.zone.now, kase.completed_at, 1.0)

    assert_length(kase.events, 1)
    assert_instance_of(Case::Events::DidComplete, kase.events[0])
  end

  test "makes a referral to a new program" do
    kase = Case.stub(
      program: Program::Meap,
      status: Case::Status::Approved,
      documents: [
        Document.stub
      ]
    )

    referral = kase.make_referral_to_program(Program::Wrap)
    assert(kase.referrer?)

    assert_not_nil(referral)
    assert(referral.referral?)
    assert_equal(referral.program, Program::Wrap)

    documents = referral.documents
    assert_length(documents, kase.documents.length)

    assert_length(kase.events, 1)
    event = kase.events[0]
    assert_instance_of(Case::Events::DidMakeReferral, event)
    assert_equal(event.case_program, Program::Wrap)

    assert_length(referral.events, 1)
    event = referral.events[0]
    assert_instance_of(Case::Events::DidOpen, event)
    assert(event.case_is_referral)
  end

  # -- commands/messages
  test "adds the first message" do
    kase = Case.stub

    kase.add_message(Message.stub)
    assert_not_nil(kase.received_message_at)

    assert_length(kase.events, 1)
    assert_instance_of(Case::Events::DidReceiveMessage, kase.events[0])
  end

  test "uploads message attachments" do
    kase = Case.stub(
      received_message_at: Time.zone.now
    )

    message = Message.new(
      sender: Message::Sender.stub,
      attachments: [
        Message::Attachment.new(
          url: "https://website.com/image.jpg"
        )
      ]
    )

    kase.add_message(message)
    assert_length(kase.new_documents, 1)
    assert_length(kase.events, 2)
    assert_instance_of(Case::Events::DidReceiveMessage, kase.events[0])
    assert_instance_of(Case::Events::DidUploadMessageAttachment, kase.events[1])

    new_document = kase.new_documents[0]
    assert_equal(new_document.classification, :unknown)
    assert_equal(new_document.source_url, "https://website.com/image.jpg")
  end

  test "signs a contract" do
    kase = Case.stub

    kase.sign_contract
    assert_length(kase.new_documents, 1)
    assert_length(kase.events, 1)
    assert_instance_of(Case::Events::DidSignContract, kase.events[0])

    new_contract = kase.new_documents[0]
    assert_equal(new_contract.classification, :contract)
  end

  test "doesn't sign a contract when one already exists" do
    kase = Case.stub(
      documents: [
        Document.stub(classification: :contract)
      ]
    )

    kase.sign_contract
    assert_nil(kase.new_documents)
    assert_length(kase.events, 0)
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

  # -- queries --
  test "has an fpl percentage with a household" do
    household = Recipient::Household.new(
      size: 5,
      income_cents: 2493_33
    )

    kase = Case.stub(
      recipient: Recipient.stub(
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
    household = Recipient::Household.new(
      size: nil,
      income_cents: 2493_33
    )

    kase = Case.stub(
      recipient: Recipient.stub(
        dhs_account: Recipient::DhsAccount.stub(
          household: household
        )
      )
    )

    assert_nil(kase.fpl_percentage)
  end

  test "has an contract" do
    kase = Case.stub(
      documents: [Document.stub(classification: :contract)]
    )

    assert_not_nil(kase.contract)
  end
end
