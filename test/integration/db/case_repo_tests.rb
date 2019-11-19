require "test_helper"

module Db
  class CaseRepoTests < ActiveSupport::TestCase
    test "finds a case by id" do
      case_repo = Case::Repo.new
      case_rec = cases(:approved_1)

      kase = case_repo.find(case_rec.id)
      assert_not_nil(kase)
    end

    test "can't find a case with an unknown id" do
      case_repo = Case::Repo.new

      assert_raises(ActiveRecord::RecordNotFound) do
        case_repo.find(1)
      end
    end

    test "finds a case by phone number" do
      case_repo = Case::Repo.new
      recipient_rec = recipients(:recipient_1)

      kase = case_repo.find_by_phone_number(recipient_rec.phone_number)
      assert_not_nil(kase)
      assert_equal(kase.recipient.profile.phone.number, recipient_rec.phone_number)
    end

    test "finds a case and document by id" do
      case_repo = Case::Repo.new
      case_rec = cases(:submitted_1)
      document_rec = documents(:document_s1_1)

      kase = case_repo.find_with_document(case_rec.id, document_rec.id)
      assert_equal(kase.id.val, case_rec.id)
      assert_length(kase.documents, 1)
      assert_equal(kase.documents[0].id.val, document_rec.id)
    end

    test "can't find a case and document if the case id does not match" do
      case_repo = Case::Repo.new
      case_rec = cases(:submitted_2)
      document_rec = documents(:document_s1_1)

      assert_raises(ActiveRecord::RecordNotFound) do
        case_repo.find_with_document(case_rec.id, document_rec.id)
      end
    end

    test "finds a submitted case by id for an enroller" do
      case_repo = Case::Repo.new
      case_rec = cases(:submitted_1)

      kase = case_repo.find_by_enroller_with_documents(case_rec.id, case_rec.enroller_id)
      assert_not_nil(kase)
      assert_equal(kase.status, :submitted)
    end

    test "can't find a non-submitted case for an enroller" do
      case_repo = Case::Repo.new
      case_rec = cases(:opened_1)

      assert_raises(ActiveRecord::RecordNotFound) do
        case_repo.find_by_enroller_with_documents(case_rec.id, case_rec.enroller_id)
      end
    end

    test "can't find another enroller's case" do
      case_repo = Case::Repo.new
      case_rec1 = cases(:submitted_1)
      case_rec2 = cases(:submitted_2)

      assert_raises(ActiveRecord::RecordNotFound) do
        case_repo.find_by_enroller_with_documents(case_rec1.id, case_rec2.enroller_id)
      end
    end

    test "finds an opened case by id" do
      case_repo = Case::Repo.new
      case_rec = cases(:opened_1)

      kase = case_repo.find_opened_with_documents(case_rec.id)
      assert_not_nil(kase)
      assert_equal(kase.status, :opened)
    end

    test "can't find an opened case by id" do
      case_repo = Case::Repo.new
      case_rec = cases(:submitted_1)

      assert_raises(ActiveRecord::RecordNotFound) do
        case_repo.find_opened_with_documents(case_rec.id)
      end
    end

    test "finds all incomplete cases" do
      case_repo = Case::Repo.new
      cases = case_repo.find_all_incomplete
      assert_length(cases, 6)
    end

    test "finds all submitted cases for an enroller" do
      case_repo = Case::Repo.new
      case_rec = cases(:submitted_1)

      cases = case_repo.find_all_for_enroller(case_rec.enroller_id)
      assert_length(cases, 2)
    end

    test "finds all opened cases" do
      case_repo = Case::Repo.new
      cases = case_repo.find_all_for_dhs
      assert_length(cases, 4)
    end

    # -- test/save
    test "saves an opened case with account and profile" do
      event_queue = EventQueue.new

      kase = Case.open(
        profile: Recipient::Profile.new(
          phone: Recipient::Phone.new(
            number: Faker::PhoneNumber.phone_number
          ),
          name: Recipient::Name.new(
            first: "Janice",
            last: "Sample"
          ),
          address: Recipient::Address.new(
            street: "123 Test St.",
            city: "Testburg",
            state: "Testissippi",
            zip: "12345"
          )
        ),
        account: Case::Account.new(
          number: "12345",
          arrears_cents: 1000_00
        ),
        enroller: Enroller::Repo.map_record(enrollers(:enroller_1)),
        supplier: Supplier::Repo.map_record(suppliers(:supplier_1))
      )

      case_repo = Case::Repo.new(event_queue: event_queue)
      act = -> do
        case_repo.save_account_and_recipient_profile(kase)
      end

      assert_difference(
        -> { Case::Record.count } => 1,
        -> { Recipient::Record.count } => 1,
        &act
      )

      assert_not_nil(kase.record)
      assert_not_nil(kase.id.val)
      assert_not_nil(kase.recipient.record)
      assert_not_nil(kase.recipient.id)

      assert_length(kase.events, 0)
      assert_length(event_queue, 1)
    end

    test "saves an opened case for an existing recipient" do
      event_queue = EventQueue.new

      kase = Case.open(
        profile: Recipient::Profile.new(
          phone: Recipient::Phone.new(
            number: recipients(:recipient_1).phone_number
          ),
          name: Recipient::Name.new(
            first: "Janice",
            last: "Sample"
          ),
          address: Recipient::Address.new(
            street: "123 Test St.",
            city: "Testburg",
            state: "Testissippi",
            zip: "12345"
          )
        ),
        account: Case::Account.new(
          number: "12345",
          arrears_cents: 1000_00
        ),
        enroller: Enroller::Repo.map_record(enrollers(:enroller_1)),
        supplier: Supplier::Repo.map_record(suppliers(:supplier_1))
      )

      case_repo = Case::Repo.new(event_queue: event_queue)
      act = -> do
        case_repo.save_account_and_recipient_profile(kase)
      end

      assert_difference(
        -> { Case::Record.count } => 1,
        -> { Recipient::Record.count } => 0,
        &act
      )

      assert_not_nil(kase.record)
      assert_not_nil(kase.id.val)
      assert_not_nil(kase.recipient.record)
      assert_not_nil(kase.recipient.id)

      assert_length(kase.events, 0)
      assert_length(event_queue, 1)
    end

    test "saves the status and dhs account" do
      case_rec = cases(:opened_1)
      kase = Case::Repo.map_record(case_rec)
      kase.attach_dhs_account(
        Recipient::DhsAccount.new(
          number: "11111",
          household: Recipient::Household.new(
            size: 3,
            income_cents: 999_00
          )
        )
      )

      case_repo = Case::Repo.new
      case_repo.save_status_and_dhs_account(kase)

      case_rec = kase.record
      assert_equal(case_rec.status, "pending")

      recipient_rec = case_rec.recipient
      assert_equal(recipient_rec.dhs_number, "11111")
      assert_equal(recipient_rec.household_size, 3)
      assert_equal(recipient_rec.household_income_cents, 999_00)
    end

    test "saves all fields and new documents" do
      event_queue = EventQueue.new

      case_rec = cases(:pending_2)
      account = Recipient::DhsAccount.new(
        number: "11111",
        household: Recipient::Household.new(
          size: 3,
          income_cents: 999_00
        )
      )

      kase = Case::Repo.map_record(case_rec)
      kase.attach_dhs_account(account)
      kase.sign_contract
      kase.submit_to_enroller
      kase.complete(:approved)

      case_repo = Case::Repo.new(event_queue: event_queue)
      case_repo.save_all_fields_and_new_documents(kase)

      case_rec = kase.record
      assert_equal(case_rec.status, "approved")
      assert_not_nil(case_rec.completed_at)

      recipient_rec = case_rec.recipient
      assert_equal(recipient_rec.dhs_number, "11111")
      assert_equal(recipient_rec.household_size, 3)
      assert_equal(recipient_rec.household_income_cents, 999_00)

      document_rec = kase.new_documents[0].record
      assert_not_nil(document_rec)

      assert_length(kase.events, 0)
      assert_length(event_queue, 3)
    end

    test "saves new documents" do
      event_queue = EventQueue.new

      case_rec = cases(:submitted_2)
      kase = Case::Repo.map_record(case_rec)
      kase.upload_message_attachments(Message.stub(
        attachments: [
          Message::Attachment.new(
            url: Faker::Internet.url
          )
        ]
      ))

      case_repo = Case::Repo.new(event_queue: event_queue)
      act = -> do
        case_repo.save_new_documents(kase)
      end

      assert_difference(
        -> { Document::Record.count } => 1,
        &act
      )

      document = kase.new_documents[0]
      assert_not_nil(document.record)
      assert_not_nil(document.id.val)

      document_rec = document.record
      assert_not_nil(document_rec)
      assert_not_nil(document_rec.case_id)
      assert_not_nil(document_rec.source_url)

      assert_length(kase.events, 0)
      assert_length(event_queue, 1)
    end

    test "saves an attached file" do
      case_rec = cases(:submitted_1)
      kase = Case::Repo.map_record(case_rec, case_rec.documents)

      kase.select_document(1)
      kase.attach_file_to_selected_document(FileData.new(
        data: StringIO.new("test-data"),
        name: "test.txt",
        mime_type: "text/plain"
      ))

      case_repo = Case::Repo.new
      act = -> do
        case_repo.save_attached_file(kase)
      end

      assert_difference(
        -> { ActiveStorage::Attachment.count } => 1,
        -> { ActiveStorage::Blob.count } => 1,
        &act
      )

      document_rec = kase.selected_document.record
      assert(document_rec.file.attached?)
    end
  end
end
