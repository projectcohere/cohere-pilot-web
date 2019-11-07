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
    kase = Case.new(
      status: :opened,
      recipient: Recipient.new(profile: nil),
      account: nil,
      enroller_id: nil,
      supplier_id: nil
    )

    kase.attach_dhs_account(:test_account)
    assert_equal(kase.recipient.dhs_account, :test_account)
    assert_equal(kase.status, :pending)
  end

  test "doesn't revert to back pending" do
    kase = Case.new(
      status: :submitted,
      recipient: Recipient.new(profile: nil),
      account: nil,
      enroller_id: nil,
      supplier_id: nil
    )

    kase.attach_dhs_account(:test_account)
    assert_equal(kase.status, :submitted)
  end

  test "submits the case" do
    kase = Case.new(
      status: :pending,
      recipient: Recipient.new(profile: nil),
      account: nil,
      enroller_id: nil,
      supplier_id: nil
    )

    kase.submit
    assert_equal(kase.status, :submitted)

    assert_length(kase.events, 1)
    assert_instance_of(Case::Events::DidSubmit, kase.events[0])
  end

  test "uploads documents from a message" do
    kase = Case.new(
      id: 4,
      status: nil,
      recipient: nil,
      account: nil,
      enroller_id: nil,
      supplier_id: nil
    )

    message = Message.new(
      sender: Message::Sender.new(
        phone_number: nil
      ),
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
end
