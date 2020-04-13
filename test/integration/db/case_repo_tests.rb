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

      document = kase.selected_document
      assert_length(kase.documents, 1)
      assert_equal(document.id.val, document_rec.id)
    end

    test "finds a case and assignment by id" do
      case_repo = Case::Repo.new
      case_rec = cases(:opened_1)
      case_assignment_rec = case_assignments(:cohere_1)

      kase = case_repo.find_with_assignment(case_rec.id, case_assignment_rec.id)
      assert_equal(kase.id.val, case_rec.id)

      assignment = kase.selected_assignment
      assert_length(kase.assignments, 1)
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

      kase = case_repo.find_with_associations(case_rec.id)
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

    test "can't find a unsubmitted case for an enroller" do
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

    test "finds an opened case by id for a governor user" do
      case_repo = Case::Repo.new
      case_rec = cases(:opened_1)

      kase = case_repo.find_with_documents_for_governor(case_rec.id)
      assert_not_nil(kase)
      assert_equal(kase.status, Case::Status::Opened)
    end

    test "can't find an submitted case by id for a governor user" do
      case_repo = Case::Repo.new
      case_rec = cases(:submitted_1)

      assert_raises(ActiveRecord::RecordNotFound) do
        case_repo.find_with_documents_for_governor(case_rec.id)
      end
    end

    test "finds an active case by recipient id" do
      case_repo = Case::Repo.new
      case_recipient_rec = recipients(:recipient_1)

      kase = case_repo.find_active_by_recipient(case_recipient_rec.id)
      assert_not_nil(kase)
      assert_equal(kase.recipient.id.val, case_recipient_rec.id)
    end

    test "finds a page of assigned cases" do
      case_repo = Case::Repo.new
      user_rec = users(:cohere_1)

      case_page, cases = case_repo.find_all_assigned_by_user(Id.new(user_rec.id), page: 1)
      assert_length(cases, 1)
      assert_equal(case_page.count, 1)
    end

    test "finds a page of opened cases for a supplier" do
      case_repo = Case::Repo.new
      partner_rec = partners(:supplier_1)

      case_page, cases = case_repo.find_all_opened_for_supplier(partner_rec.id, page: 1)
      assert_length(cases, 7)
      assert_equal(case_page.count, 7)
      assert(cases.any? { |c| c.selected_assignment != nil })
    end

    test "finds a page of queued cases for a governor user" do
      case_repo = Case::Repo.new
      partner_rec = partners(:governor_1)

      case_page, cases = case_repo.find_all_queued_for_governor(partner_rec.id, page: 1)
      assert_length(cases, 4)
      assert_equal(case_page.count, 4)
    end

    test "finds a page of opened cases for a governor user" do
      case_repo = Case::Repo.new
      partner_rec = partners(:governor_1)

      case_page, cases = case_repo.find_all_opened_for_governor(partner_rec.id, page: 1)
      assert_length(cases, 5)
      assert_equal(case_page.count, 5)
      assert(cases.any? { |c| c.selected_assignment != nil })
    end

    test "finds a page of queued cases for an enroller" do
      case_repo = Case::Repo.new
      partner_rec = partners(:enroller_1)

      case_page, cases = case_repo.find_all_queued_for_enroller(partner_rec.id, page: 1)
      assert_length(cases, 0)
      assert_equal(case_page.count, 0)
    end

    test "finds a page of submitted cases for an enroller" do
      case_repo = Case::Repo.new
      partner_rec = partners(:enroller_1)

      case_page, cases = case_repo.find_all_submitted_for_enroller(partner_rec.id, page: 1)
      assert_length(cases, 3)
      assert_equal(case_page.count, 3)
      assert(cases.any? { |c| c.selected_assignment != nil })
    end

    # -- test/save
    test "saves an opened case" do
      case_repo = Case::Repo.new

      recipient_profile = Recipient::Profile.stub(
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
      )

      supplier_account = Case::Account.stub(
        number: "12345",
        arrears_cents: 1000_00
      )

      user_rec = users(:supplier_2)

      kase = Case.open(
        recipient_profile: recipient_profile,
        enroller: Partner::Repo.map_record(partners(:enroller_1)),
        supplier: Partner::Repo.map_record(user_rec.partner),
        supplier_account: supplier_account,
      )

      kase.assign_user(User::Repo.map_record(user_rec))

      act = -> do
        case_repo.save_opened(kase)
      end

      assert_difference(
        -> { Case::Record.count } => 1,
        -> { Case::Assignment::Record.count } => 1,
        -> { Recipient::Record.count } => 1,
        &act
      )

      assert_not_nil(kase.record)
      assert_not_nil(kase.id.val)
      assert_not_nil(kase.recipient.record)
      assert_not_nil(kase.recipient.id.val)

      case_rec = kase.record
      assert_equal(case_rec.program, "wrap")

      events = kase.events
      assert_length(events, 0)
      assert_length(Service::Container.domain_events, 2)
    end

    test "saves an opened case for an existing recipient" do
      case_repo = Case::Repo.new

      recipient_profile = Recipient::Profile.new(
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

      user_rec = users(:supplier_1)

      kase = Case.open(
        recipient_profile: recipient_profile,
        enroller: Partner::Repo.map_record(partners(:enroller_1)),
        supplier: Partner::Repo.map_record(user_rec.partner),
        supplier_account: supplier_account,
      )

      kase.assign_user(User::Repo.map_record(user_rec))

      act = -> do
        case_repo.save_opened(kase)
      end

      assert_difference(
        -> { Case::Record.count } => 1,
        -> { Case::Assignment::Record.count } => 1,
        -> { Recipient::Record.count } => 0,
        &act
      )

      assert_not_nil(kase.record)
      assert_not_nil(kase.id.val)
      assert_not_nil(kase.recipient.record)
      assert_not_nil(kase.recipient.id.val)

      events = kase.events
      assert_length(events, 0)
      assert_length(Service::Container.domain_events, 2)
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
      case_repo = Case::Repo.new
      case_rec = cases(:opened_2)

      supplier_account = Case::Account.new(
        number: "12345",
        arrears_cents: 1000_00
      )

      recipient_profile = Recipient::Profile.new(
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
      kase.add_cohere_data(supplier_account, recipient_profile, dhs_account)
      kase.sign_contract(contract)
      kase.submit_to_enroller
      kase.complete(Case::Status::Approved)

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

      events = kase.events
      assert_length(events, 0)
      assert_length(Service::Container.domain_events, 4)
    end

    test "saves a new assignment" do
      case_repo = Case::Repo.new
      case_rec = cases(:opened_2)
      user_rec = users(:cohere_1)

      kase = Case::Repo.map_record(case_rec)
      user = User::Repo.map_record(user_rec)
      kase.assign_user(user)

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

      events = kase.events
      assert_length(events, 0)
      assert_length(Service::Container.domain_events, 1)
    end

    test "saves a destroyed assignment" do
      case_repo = Case::Repo.new
      case_rec = cases(:opened_1)
      case_assignment_rec = case_rec.assignments.first

      kase = Case::Repo.map_record(case_rec, assignments: [case_assignment_rec])
      kase.select_assignment(case_assignment_rec.partner_id)
      kase.destroy_selected_assignment

      act = -> do
        case_repo.save_destroyed_assignment(kase)
      end

      assert_difference(
        -> { Case::Assignment::Record.count } => -1,
        &act
      )

      assignment_recs = case_rec.reload.assignments
      assert(assignment_recs.none? { |a| a.id == case_assignment_rec.id })

      events = kase.events
      assert_length(events, 0)
      assert_length(Service::Container.domain_events, 1)
    end

    test "saves a new message" do
      case_repo = Case::Repo.new
      case_rec = cases(:pending_1)

      kase = Case::Repo.map_record(case_rec)
      kase.add_chat_message(Chat::Message.stub(
        sender: Chat::Sender.recipient,
        attachments: [
          Chat::Attachment.stub(file: {
            io: StringIO.new("test"),
            filename: "test.txt",
          }),
        ],
      ))

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

      events = kase.events
      assert_length(events, 0)
      assert_length(Service::Container.domain_events, 1)
    end

    test "saves the selected attachment" do
      case_repo = Case::Repo.new
      case_rec = cases(:submitted_1)

      kase = Case::Repo.map_record(case_rec, documents: case_rec.documents)
      kase.select_document(1)
      kase.attach_file_to_selected_document(FileData.new(
        data: StringIO.new("test-data"),
        name: "test.txt",
        mime_type: "text/plain"
      ))

      act = -> do
        case_repo.save_selected_document(kase)
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
      case_repo = Case::Repo.new
      case_rec = cases(:submitted_1)

      kase = Case::Repo.map_record(case_rec, documents: case_rec.documents)
      kase.complete(Case::Status::Approved)

      case_repo.save_completed(kase)
      assert_equal(case_rec.status, "approved")
      assert_not_nil(case_rec.completed_at)
    end

    test "saves a referral" do
      case_repo = Case::Repo.new
      case_rec = cases(:approved_1)
      user_rec = users(:cohere_1)
      supplier_rec = partners(:supplier_3)

      referrer = Case::Repo.map_record(case_rec, documents: case_rec.documents)
      referral = referrer.make_referral(
        supplier_id: supplier_rec.id
      )

      referred = referral.referred
      referred.assign_user(
        User::Repo.map_record(user_rec)
      )

      referred.sign_contract(Program::Contract.new(
        program: Program::Name::Wrap,
        variant: Program::Contract::Wrap3h
      ))

      act = -> do
        case_repo.save_referral(referral)
      end

      assert_difference(
        -> { Case::Record.count } => 1,
        -> { Case::Assignment::Record.count } => 1,
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
      assert_length(Service::Container.domain_events, 4)
    end
  end
end
