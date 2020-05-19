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
      document_rec = documents(:document_s1_c)

      kase = case_repo.find_with_document(case_rec.id, document_rec.id)
      assert_equal(kase.id.val, case_rec.id)

      document = kase.selected_document
      assert_length(kase.documents, 1)
      assert_equal(document.id.val, document_rec.id)
    end

    test "finds a case and assignment by id" do
      case_repo = Case::Repo.new
      case_rec = cases(:opened_1)
      partner_rec = partners(:cohere_1)

      kase = case_repo.find_with_assignment(case_rec.id, partner_rec.id)
      assert_equal(kase.id.val, case_rec.id)

      assignment = kase.selected_assignment
      assert_length(kase.assignments, 1)
    end

    test "can't find a case and document if the case id does not match" do
      case_repo = Case::Repo.new
      case_rec = cases(:submitted_2)
      document_rec = documents(:document_s1_c)

      assert_raises(ActiveRecord::RecordNotFound) do
        case_repo.find_with_document(case_rec.id, document_rec.id)
      end
    end

    test "finds a case with associations" do
      case_repo = Case::Repo.new
      case_rec = cases(:approved_2)

      kase = case_repo.find_with_associations(case_rec.id)
      assert_equal(kase.id.val, case_rec.id)
      assert_length(kase.documents, 2)
    end

    test "finds a submitted case as an enroller" do
      case_repo = Case::Repo.new
      case_rec = cases(:submitted_1)
      user_rec = users(:enroller_1)
      User::Repo.get.sign_in(user_rec)

      kase = case_repo.find_with_associations(case_rec.id)
      assert_not_nil(kase)
      assert_equal(kase.status, Case::Status::Submitted)
    end

    test "can't find a unsubmitted case as an enroller" do
      case_repo = Case::Repo.new
      case_rec = cases(:opened_1)
      user_rec = users(:enroller_1)
      User::Repo.get.sign_in(user_rec)

      assert_raises(ActiveRecord::RecordNotFound) do
        case_repo.find_with_associations(case_rec.id)
      end
    end

    test "can't find another enroller's case as an enroller" do
      case_repo = Case::Repo.new
      case_rec = cases(:submitted_2)
      user_rec = users(:enroller_1)
      User::Repo.get.sign_in(user_rec)

      assert_raises(ActiveRecord::RecordNotFound) do
        case_repo.find_with_associations(case_rec.id)
      end
    end

    test "finds an opened case by id for a governor" do
      case_repo = Case::Repo.new
      case_rec = cases(:opened_1)
      user_rec = users(:governor_1)
      User::Repo.get.sign_in(user_rec)

      kase = case_repo.find_with_associations(case_rec.id)
      assert_not_nil(kase)
      assert_equal(kase.status, Case::Status::Opened)
    end

    test "can't find a submitted case by id for a governor" do
      case_repo = Case::Repo.new
      case_rec = cases(:submitted_1)
      user_rec = users(:governor_1)
      User::Repo.get.sign_in(user_rec)

      assert_raises(ActiveRecord::RecordNotFound) do
        case_repo.find_with_associations(case_rec.id)
      end
    end

    test "finds a case by chat recipient" do
      case_repo = Case::Repo.new
      case_recipient_rec = recipients(:recipient_1)

      kase = case_repo.find_by_chat_recipient(case_recipient_rec.id)
      assert_not_nil(kase)
      assert_equal(kase.recipient.id.val, case_recipient_rec.id)
    end

    # -- test/save
    test "saves an opened case" do
      case_repo = Case::Repo.new

      user_rec = users(:source_2)
      supplier_rec = user_rec.partner
      program_rec = supplier_rec.programs.first
      enroller_rec = partners(:enroller_1)

      profile = Recipient::Profile.stub(
        phone: Phone.stub(
          number: Faker::PhoneNumber.phone_number
        ),
        name: Name.stub(
          first: "Janice",
          last: "Sample"
        ),
        address: Address.stub(
          street: "123 Test St.",
          city: "Testburg",
          state: "Testissippi",
          zip: "12345"
        )
      )

      household = Recipient::Household.stub(
        proof_of_income: Recipient::ProofOfIncome::Weatherization,
        ownership: Recipient::Ownership::Own,
      )

      supplier_account = Case::Account.stub(
        supplier_id: supplier_rec.id,
        number: "12345",
        arrears: Money.cents(1000_00),
      )

      food = Case::Food.new(
        dietary_restrictions: false,
      )

      kase = Case.open(
        temp_id: 9,
        program: Program::Repo.map_record(program_rec),
        profile: profile,
        household: household,
        enroller: Partner::Repo.map_record(enroller_rec),
        supplier_account: supplier_account,
        food: food,
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
      assert(case_rec.opened?)
      assert(case_rec.active?)
      assert_equal(case_rec.program.id, program_rec.id)
      assert_not(case_rec.dietary_restrictions?)

      events = kase.events
      assert_length(events, 0)
      assert_length(Events::DispatchAll.get.events, 2)
    end

    test "saves an opened case for an existing recipient" do
      case_repo = Case::Repo.new

      user_rec = users(:source_1)
      enroller_rec = partners(:enroller_1)
      supplier_rec = user_rec.partner
      program_rec = supplier_rec.programs.first

      profile = Recipient::Profile.new(
        phone: Phone.new(
          number: "1112223333"
        ),
        name: Name.new(
          first: "Janice",
          last: "Sample"
        ),
        address: Address.new(
          street: "123 Test St.",
          city: "Testburg",
          state: "Testissippi",
          zip: "12345"
        )
      )

      household = Recipient::Household.stub(
        proof_of_income: Recipient::ProofOfIncome::Uia,
        ownership: Recipient::Ownership::Rent,
      )

      supplier_account = Case::Account.new(
        supplier_id: supplier_rec.id,
        number: "12345",
        arrears: Money.cents(1000_00),
      )

      kase = Case.open(
        temp_id: 9,
        program: Program::Repo.map_record(program_rec),
        profile: profile,
        household: household,
        enroller: Partner::Repo.map_record(enroller_rec),
        supplier_account: nil,
        food: nil,
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
      assert_length(Events::DispatchAll.get.events, 2)
    end

    test "saves governor data" do
      case_rec = cases(:opened_1)

      kase = Case::Repo.map_record(case_rec)
      kase.add_governor_data(Recipient::Household.stub(
        dhs_number: "11111",
        size: 3,
        income: Money.cents(999_00),
      ))

      case_repo = Case::Repo.new
      case_repo.save_governor_data(kase)

      case_rec = kase.record
      assert(case_rec.new_activity)

      recipient_rec = case_rec.recipient
      assert_equal(recipient_rec.dhs_number, "11111")
      assert_equal(recipient_rec.household_size, 3)
      assert_equal(recipient_rec.household_income_cents, 999_00)
    end

    test "saves agent data" do
      case_repo = Case::Repo.new
      case_rec = cases(:opened_2)

      profile = Recipient::Profile.new(
        phone: Phone.new(
          number: "1112223333"
        ),
        name: Name.new(
          first: "Janice",
          last: "Sample"
        ),
        address: Address.new(
          street: "123 Test St.",
          city: "Testburg",
          state: "Testissippi",
          zip: "12345"
        )
      )

      household = Recipient::Household.new(
        size: 3,
        proof_of_income: Recipient::ProofOfIncome::Uia,
        income: Money.cents(999_00),
        dhs_number: "11111",
        ownership: Recipient::Ownership::Rent,
      )

      supplier_account = Case::Account.new(
        supplier_id: case_rec.supplier_id,
        number: "12345",
        arrears: Money.cents(1000_00),
      )

      food = Case::Food.new(
        dietary_restrictions: true,
      )

      contract = Program::Contract.new(
        variant: :wrap_1k
      )

      kase = Case::Repo.map_record(case_rec)
      kase.add_agent_data(profile, household, supplier_account, food)
      kase.sign_contract(contract)
      kase.submit_to_enroller
      kase.complete(Case::Status::Approved, Money.cents(123_44))

      case_repo.save_agent_data(kase)

      c = case_rec
      assert(c.approved?)
      assert(c.dietary_restrictions?)
      assert_equal(c.supplier_account_number, "12345")
      assert_equal(c.supplier_account_arrears_cents, 1000_00)
      assert_equal(c.benefit_amount_cents, 123_44)
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
      assert_equal(r.household_proof_of_income, "uia")
      assert_equal(r.household_income_cents, 999_00)
      assert_equal(r.household_ownership, "rent")

      d = kase.new_documents[0].record
      assert_not_nil(d)
      assert(d.contract?)
      assert_equal(d.source_url, "wrap_1k")

      events = kase.events
      assert_length(events, 0)
      assert_length(Events::DispatchAll.get.events, 4)
    end

    test "saves a new assignment" do
      case_repo = Case::Repo.new
      case_rec = cases(:opened_2)
      user_rec = users(:agent_1)

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
      assert_length(Events::DispatchAll.get.events, 1)
    end

    test "saves a new note" do
      case_repo = Case::Repo.new
      case_rec = cases(:opened_2)
      user_rec = users(:agent_1)

      kase = Case::Repo.map_record(case_rec)
      user = User::Repo.map_record(user_rec)
      kase.add_note("Test note.", user)

      act = -> do
        case_repo.save_new_note(kase)
      end

      assert_difference(
        -> { Case::Note::Record.count } => 1,
        &act
      )

      note_rec = case_rec.notes.first
      assert_not_nil(note_rec)
      assert_equal(note_rec.body, "Test note.")
      assert_equal(note_rec.user_id, user_rec.id)
      assert_equal(note_rec.case_id, case_rec.id)

      events = kase.events
      assert_length(events, 0)
      assert_length(Events::DispatchAll.get.events, 0)
    end

    test "saves a removed assignment" do
      case_repo = Case::Repo.new
      case_rec = cases(:opened_1)
      case_assignment_rec = case_rec.assignments.first

      kase = Case::Repo.map_record(case_rec, assignments: [case_assignment_rec])
      kase.select_assignment(case_assignment_rec.partner_id)
      kase.remove_selected_assignment

      act = -> do
        case_repo.save_removed_assignment(kase)
      end

      assert_difference(
        -> { Case::Assignment::Record.count } => -1,
        &act
      )

      assignment_recs = case_rec.reload.assignments
      assert(assignment_recs.none? { |a| a.id == case_assignment_rec.id })

      events = kase.events
      assert_length(events, 0)
      assert_length(Events::DispatchAll.get.events, 1)
    end

    test "saves a new message" do
      case_repo = Case::Repo.new
      case_rec = cases(:opened_3)

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
      assert_length(Events::DispatchAll.get.events, 1)
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

    test "saves a returned case" do
      case_repo = Case::Repo.new
      case_rec = cases(:submitted_1)
      kase = Case::Repo.map_record(case_rec, assignments: case_rec.assignments)
      kase.return_to_agent

      case_repo.save_returned(kase)
      assert(case_rec.returned?)
      assert_length(case_rec.assignments.reload, 2)

      events = kase.events
      assert_length(events, 0)
      assert_length(Events::DispatchAll.get.events, 3)
    end

    test "saves a completed case" do
      case_repo = Case::Repo.new
      case_rec = cases(:submitted_1)
      kase = Case::Repo.map_record(case_rec, assignments: case_rec.assignments, documents: case_rec.documents)
      kase.complete(Case::Status::Approved, Money.new(123_99))

      case_repo.save_completed(kase)
      assert(case_rec.approved?)
      assert(case_rec.benefit_amount_cents, 129_99)
      assert_length(case_rec.assignments.reload, 2)
      assert_not_nil(case_rec.completed_at)

      events = kase.events
      assert_length(events, 0)
      assert_length(Events::DispatchAll.get.events, 3)
    end

    test "saves a deleted case" do
      case_repo = Case::Repo.new
      case_rec = cases(:opened_1)
      kase = Case::Repo.map_record(case_rec)
      kase.delete

      case_repo.save_deleted(kase)
      assert(case_rec.deleted?)

      events = kase.events
      assert_length(events, 0)
      assert_length(Events::DispatchAll.get.events, 0)
    end

    test "saves an archived case" do
      case_repo = Case::Repo.new
      case_rec = cases(:opened_1)
      kase = Case::Repo.map_record(case_rec)
      kase.archive

      case_repo.save_archived(kase)
      assert(case_rec.archived?)

      events = kase.events
      assert_length(events, 0)
      assert_length(Events::DispatchAll.get.events, 0)
    end

    test "saves a referral" do
      case_repo = Case::Repo.new
      case_rec = cases(:approved_1)
      program_rec = programs(:water_0)
      supplier_rec = partners(:supplier_3)
      user_rec = users(:agent_1)

      referrer = Case::Repo.map_record(case_rec, documents: case_rec.documents)
      referral = referrer.make_referral(Program::Repo.map_record(program_rec))

      referred = referral.referred
      referred.assign_user(User::Repo.map_record(user_rec))
      referred.sign_contract(Program::Contract.new(variant: :wrap_3h))

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
      assert(referred_rec.opened?)
      assert(referred_rec.active?)
      assert_equal(referred_rec.program.id, program_rec.id)

      referrer_rec = referrer.record.reload
      assert(referrer_rec.archived?)

      document_recs = referred_rec.documents
      assert_same_elements(document_recs.map(&:classification), %w[contract unknown])

      assert_length(referrer.events, 0)
      assert_length(referred.events, 0)
      assert_length(Events::DispatchAll.get.events, 4)
    end
  end
end
