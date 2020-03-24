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

    test "finds a case with its documents and referral" do
      case_repo = Case::Repo.new
      case_rec = cases(:approved_2)

      kase = case_repo.find_with_documents_and_referral(case_rec.id)
      assert_equal(kase.id.val, case_rec.id)
      assert_length(kase.documents, 2)
      assert(kase.is_referrer)
    end

    test "finds a submitted case by id for an enroller" do
      case_repo = Case::Repo.new
      case_rec = cases(:submitted_1)

      kase = case_repo.find_with_documents_for_enroller(case_rec.id, case_rec.enroller_id)
      assert_not_nil(kase)
      assert_equal(kase.status, Case::Status::Submitted)
    end

    test "can't find a non-submitted case for an enroller" do
      case_repo = Case::Repo.new
      case_rec = cases(:opened_1)

      assert_raises(ActiveRecord::RecordNotFound) do
        case_repo.find_with_documents_for_enroller(case_rec.id, case_rec.enroller_id)
      end
    end

    test "can't find another enroller's case" do
      case_repo = Case::Repo.new
      case_rec1 = cases(:submitted_1)
      case_rec2 = cases(:submitted_2)

      assert_raises(ActiveRecord::RecordNotFound) do
        case_repo.find_with_documents_for_enroller(case_rec1.id, case_rec2.enroller_id)
      end
    end

    test "finds an opened case by id" do
      case_repo = Case::Repo.new
      case_rec = cases(:opened_1)

      kase = case_repo.find_opened_with_documents(case_rec.id)
      assert_not_nil(kase)
      assert_equal(kase.status, Case::Status::Opened)
    end

    test "can't find an opened case by id" do
      case_repo = Case::Repo.new
      case_rec = cases(:submitted_1)

      assert_raises(ActiveRecord::RecordNotFound) do
        case_repo.find_opened_with_documents(case_rec.id)
      end
    end

    test "finds an active case by recipient id" do
      case_repo = Case::Repo.new
      case_recipient_rec = recipients(:recipient_1)

      kase = case_repo.find_active_by_recipient(case_recipient_rec.id)
      assert_not_nil(kase)
      assert_equal(kase.recipient.id.val, case_recipient_rec.id)
    end

    test "finds a page of queued cases" do
      case_repo = Case::Repo.new
      case_page, cases = case_repo.find_all_queued_for_cohere(page: 1)
      assert_length(cases, 7)
      assert_equal(case_page.count, 7)
    end

    test "finds a page of assigned cases" do
      case_repo = Case::Repo.new
      user_rec = users(:cohere_1)

      case_page, cases = case_repo.find_all_assigned_by_user(Id.new(user_rec.id), page: 1)
      assert_length(cases, 1)
      assert_equal(case_page.count, 1)
    end

    test "finds a page of opened cases" do
      case_repo = Case::Repo.new
      case_page, cases = case_repo.find_all_opened(page: 1)
      assert_length(cases, 8)
      assert_equal(case_page.count, 8)
    end

    test "finds a page of completed cases" do
      case_repo = Case::Repo.new
      case_page, cases = case_repo.find_all_completed(page: 1)
      assert_length(cases, 2)
      assert_equal(case_page.count, 2)
    end

    test "finds a page of cases opened for an supplier" do
      case_repo = Case::Repo.new
      case_rec = cases(:opened_1)
      case_page, cases = case_repo.find_all_opened_for_supplier(case_rec.supplier_id, page: 1)
      assert_length(cases, 7)
      assert_equal(case_page.count, 7)
    end

    test "finds a page of queued cases for an enroller" do
      case_repo = Case::Repo.new
      enroller_rec = partners(:enroller_1)

      case_page, cases = case_repo.find_all_queued_for_enroller(enroller_rec.id, page: 1)
      assert_length(cases, 2)
      assert_equal(case_page.count, 2)
    end

    test "finds a page of submitted cases for an enroller" do
      case_repo = Case::Repo.new
      enroller_rec = partners(:enroller_1)

      case_page, cases = case_repo.find_all_submitted_for_enroller(enroller_rec.id, page: 1)
      assert_length(cases, 3)
      assert_equal(case_page.count, 3)
    end

    test "finds a page of dhs cases" do
      case_repo = Case::Repo.new
      case_page, cases = case_repo.find_all_for_dhs(page: 1)
      assert_length(cases, 5)
      assert_equal(case_page.count, 5)
    end

    # -- test/save
    test "saves an opened case with account and profile" do
      domain_events = ArrayQueue.new

      kase = Case.open(
        program: Program::Name::Meap,
        profile: Recipient::Profile.stub(
          phone: Recipient::Phone.stub(
            number: Faker::PhoneNumber.phone_number
          ),
          name: Recipient::Name.stub(
            first: "Janice",
            last: "Sample"
          ),
          address: Recipient::Address.stub(
            street: "123 Test St.",
            city: "Testburg",
            state: "Testissippi",
            zip: "12345"
          )
        ),
        enroller: Partner::Repo.map_record(partners(:enroller_1)),
        supplier: Partner::Repo.map_record(partners(:supplier_1)),
        supplier_account: Case::Account.stub(
          number: "12345",
          arrears_cents: 1000_00
        )
      )

      case_repo = Case::Repo.new(domain_events: domain_events)
      act = -> do
        case_repo.save_opened(kase)
      end

      assert_difference(
        -> { Case::Record.count } => 1,
        -> { Recipient::Record.count } => 1,
        &act
      )

      assert_not_nil(kase.record)
      assert_not_nil(kase.id.val)
      assert_not_nil(kase.recipient.record)
      assert_not_nil(kase.recipient.id.val)

      assert_length(kase.events, 0)
      assert_length(domain_events, 1)
    end

    test "saves an opened case for an existing recipient" do
      domain_events = ArrayQueue.new

      profile = Recipient::Profile.new(
        phone: Recipient::Phone.new(
          number: "1112223333"
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
      )

      supplier_account = Case::Account.new(
        number: "12345",
        arrears_cents: 1000_00
      )

      kase = Case.open(
        program: Program::Name::Meap,
        profile: profile,
        enroller: Partner::Repo.map_record(partners(:enroller_1)),
        supplier: Partner::Repo.map_record(partners(:supplier_1)),
        supplier_account: supplier_account,
      )

      case_repo = Case::Repo.new(domain_events: domain_events)
      act = -> do
        case_repo.save_opened(kase)
      end

      assert_difference(
        -> { Case::Record.count } => 1,
        -> { Recipient::Record.count } => 0,
        &act
      )

      assert_not_nil(kase.record)
      assert_not_nil(kase.id.val)
      assert_not_nil(kase.recipient.record)
      assert_not_nil(kase.recipient.id.val)

      assert_length(kase.events, 0)
      assert_length(domain_events, 1)
    end

    test "saves a dhs contribution" do
      case_rec = cases(:opened_1)

      kase = Case::Repo.map_record(case_rec)
      kase.add_dhs_data(
        Recipient::DhsAccount.new(
          number: "11111",
          household: Recipient::Household.stub(
            size: 3,
            income_cents: 999_00
          )
        )
      )

      case_repo = Case::Repo.new
      case_repo.save_dhs_contribution(kase)

      case_rec = kase.record
      assert(case_rec.has_new_activity)
      assert_equal(case_rec.status, "pending")

      recipient_rec = case_rec.recipient
      assert_equal(recipient_rec.dhs_number, "11111")
      assert_equal(recipient_rec.household_size, 3)
      assert_equal(recipient_rec.household_income_cents, 999_00)
    end

    test "saves a cohere contribution" do
      domain_events = ArrayQueue.new

      case_rec = cases(:opened_2)

      supplier_account = Case::Account.new(
        number: "12345",
        arrears_cents: 1000_00
      )

      profile = Recipient::Profile.new(
        phone: Recipient::Phone.new(
          number: "1112223333"
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
      )

      dhs_account = Recipient::DhsAccount.new(
        number: "11111",
        household: Recipient::Household.stub(
          size: 3,
          income_cents: 999_00
        )
      )

      contract = Program::Contract.new(
        program: Program::Name::Meap,
        variant: Program::Contract::Meap
      )

      kase = Case::Repo.map_record(case_rec)
      kase.add_cohere_data(supplier_account, profile, dhs_account)
      kase.sign_contract(contract)
      kase.submit_to_enroller
      kase.complete(Case::Status::Approved)

      case_repo = Case::Repo.new(domain_events: domain_events)
      case_repo.save_cohere_contribution(kase)

      c = kase.record
      assert_equal(c.status, "approved")
      assert_equal(c.supplier_account_number, "12345")
      assert_equal(c.supplier_account_arrears_cents, 1000_00)
      assert_not_nil(c.completed_at)

      r = c.recipient
      assert_equal(r.first_name, "Janice")
      assert_equal(r.last_name, "Sample")
      assert_equal(r.phone_number, "1112223333")
      assert_equal(r.street, "123 Test St.")
      assert_equal(r.city, "Testburg")
      assert_equal(r.state, "Testissippi")
      assert_equal(r.zip, "12345")
      assert_equal(r.dhs_number, "11111")
      assert_equal(r.household_size, 3)
      assert_equal(r.household_income_cents, 999_00)

      d = kase.new_documents[0].record
      assert_not_nil(d)
      assert_equal(d.classification, "contract")

      assert_length(kase.events, 0)
      assert_length(domain_events, 4)
    end

    test "saves a new assignment" do
      case_rec = cases(:opened_2)
      user_rec = users(:cohere_1)

      kase = Case::Repo.map_record(case_rec)
      user = User::Repo.map_record(user_rec)
      kase.assign_user(user)

      case_repo = Case::Repo.new
      act = -> do
        case_repo.save_new_assignment(kase)
      end

      assert_difference(
        -> { Case::Assignment::Record.count } => 1,
        &act
      )

      assignment_rec = case_rec.assignments.first
      assert_not_nil(assignment_rec)
      assert_equal(assignment_rec.case_id, case_rec.id)
      assert_equal(assignment_rec.user_id, user_rec.id)
      assert_equal(assignment_rec.partner_id, user_rec.partner_id)
    end

    test "saves a new mms message" do
      case_rec = cases(:pending_1)

      kase = Case::Repo.map_record(case_rec)
      kase.add_mms_message(Mms::Message.stub(
        sender_phone_number: kase.recipient.profile.phone.number,
        attachments: [
          Mms::Attachment.stub(
            url: Faker::Internet.url
          )
        ],
      ))

      domain_events = ArrayQueue.new
      case_repo = Case::Repo.new(domain_events: domain_events)

      act = -> do
        case_repo.save_new_message(kase)
      end

      assert_difference(
        -> { Document::Record.count } => 1,
        &act
      )

      case_rec = kase.record
      assert_not_nil(case_rec.received_message_at)

      document = kase.new_documents[0]
      assert_not_nil(document.record)
      assert_not_nil(document.id.val)

      document_rec = document.record
      assert_not_nil(document_rec)
      assert_not_nil(document_rec.case_id)
      assert_not_nil(document_rec.source_url)

      assert_length(kase.events, 0)
      assert_length(domain_events, 2)
    end

    test "saves a new chat message" do
      case_rec = cases(:pending_2)

      kase = Case::Repo.map_record(case_rec)
      kase.add_chat_message(Chat::Message.stub(
        sender: Chat::Sender.recipient,
        attachments: [
          active_storage_blobs(:blob_1)
        ]
      ))

      domain_events = ArrayQueue.new
      case_repo = Case::Repo.new(domain_events: domain_events)

      act = -> do
        case_repo.save_new_message(kase)
      end

      assert_difference(
        -> { Document::Record.count } => 1,
        &act
      )

      case_rec = kase.record
      assert_not_nil(case_rec.received_message_at)
      assert(case_rec.has_new_activity)

      document = kase.new_documents[0]
      assert_not_nil(document.record)
      assert_not_nil(document.id.val)

      document_rec = document.record
      assert_not_nil(document_rec)
      assert_not_nil(document_rec.case_id)

      assert_length(kase.events, 0)
      assert_length(domain_events, 2)
    end

    test "saves the selected attachment" do
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
        case_repo.save_selected_attachment(kase)
      end

      assert_difference(
        -> { ActiveStorage::Attachment.count } => 1,
        -> { ActiveStorage::Blob.count } => 1,
        &act
      )

      document_rec = kase.selected_document.record
      assert(document_rec.file.attached?)
    end

    test "saves completed" do
      case_rec = cases(:submitted_1)
      kase = Case::Repo.map_record(case_rec, case_rec.documents)
      kase.complete(Case::Status::Approved)
      case_repo = Case::Repo.new

      case_repo.save_completed(kase)
      assert_equal(case_rec.status, "approved")
      assert_not_nil(case_rec.completed_at)
    end

    test "saves a referral" do
      supplier_rec = partners(:supplier_3)
      case_rec = cases(:approved_1)

      referrer = Case::Repo.map_record(case_rec, case_rec.documents)
      referral = referrer.make_referral_to_program(
        Program::Name::Wrap,
        supplier_id: supplier_rec.id
      )

      referred = referral.referred
      referred.sign_contract(Program::Contract.new(
        program: Program::Name::Wrap,
        variant: Program::Contract::Wrap3h
      ))

      domain_events = ArrayQueue.new
      case_repo = Case::Repo.new(domain_events: domain_events)

      act = -> do
        case_repo.save_referral(referral)
      end

      assert_difference(
        -> { Case::Record.count } => 1,
        -> { Document::Record.count } => 2,
        -> { ActiveStorage::Attachment.count } => 1,
        -> { ActiveStorage::Blob.count } => 0,
        &act
      )

      assert_not_nil(referred.record)
      assert_not_nil(referred.id.val)

      referred_rec = referred.record
      assert_equal(referred_rec.status, "opened")
      assert_equal(referred_rec.program, "wrap")
      assert_equal(referred_rec.referrer_id, referrer.id.val)

      document_recs = referred_rec.documents
      assert_same_elements(document_recs.map(&:classification), %w[contract unknown])

      assert_length(referrer.events, 0)
      assert_length(referred.events, 0)
      assert_length(domain_events, 3)
    end
  end
end
