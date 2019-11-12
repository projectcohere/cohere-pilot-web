require "test_helper"

class CaseTests < ActiveSupport::TestCase
  test "opens the case" do
    kase = Case.open(
      profile: :test_profile,
      account: :test_account,
      enroller: Enroller.new(id: 1, name: :enroller),
      supplier: Supplier.new(id: 2, name: :supplier)
    )

    assert_equal(kase.recipient.profile, :test_profile)
    assert_equal(kase.account, :test_account)
    assert_equal(kase.enroller_id, 1)
    assert_equal(kase.supplier_id, 2)

    assert_length(kase.events, 1)
    assert_instance_of(Case::Events::DidOpen, kase.events[0])
  end

  test "attaches a dhs account" do
    kase = Case.stub(
      status: :opened,
      recipient: Recipient.stub,
    )

    kase.attach_dhs_account(:test_account)
    assert_equal(kase.recipient.dhs_account, :test_account)
    assert_equal(kase.status, :pending)
  end

  test "doesn't revert back to pending once submitted" do
    kase = Case.stub(
      status: :submitted,
      recipient: Recipient.stub
    )

    kase.attach_dhs_account(:test_account)
    assert_equal(kase.status, :submitted)
  end

  test "submits the case" do
    kase = Case.stub(
      status: :pending,
      recipient: Recipient.stub
    )

    kase.submit
    assert_equal(kase.status, :submitted)

    assert_length(kase.events, 1)
    assert_instance_of(Case::Events::DidSubmit, kase.events[0])
  end

  test "uploads documents from a message" do
    kase = Case.stub(
      id: 4
    )

    message = Message.new(
      sender: Message::Sender.stub,
      attachments: [
        Message::Attachment.new(
          url: "https://website.com/image.jpg"
        )
      ]
    )

    documents = kase.upload_documents_from_message(message)
    assert_length(documents, 1)
    assert_equal(documents[0].case_id, 4)
    assert_equal(documents[0].source_url, "https://website.com/image.jpg")
  end

  test "calcuates an fpl percentage from the household" do
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
end
