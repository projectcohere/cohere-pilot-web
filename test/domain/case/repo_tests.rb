require "test_helper"
require "minitest/mock"

class Case
  class RepoTests < ActiveSupport::TestCase
    test "finds a case by id" do
      case_repo = Case::Repo.new
      case_rec = cases(:approved_1)

      kase = case_repo.find(case_rec.id)
      assert_not_nil(kase)
    end

    test "finds a case by phone number" do
      case_repo = Case::Repo.new
      recipient_rec = recipients(:recipient_1)

      kase = case_repo.find_by_phone_number(recipient_rec.phone_number)
      assert_not_nil(kase)
      assert_equal(kase.recipient.profile.phone.number, recipient_rec.phone_number)
    end

    test "can't find a case with an unknown id" do
      case_repo = Case::Repo.new

      assert_raises(ActiveRecord::RecordNotFound) do
        case_repo.find(1)
      end
    end

    test "finds a submitted case by id for an enroller" do
      case_repo = Case::Repo.new
      case_rec = cases(:submitted_1)

      kase = case_repo.find_for_enroller(case_rec.id, case_rec.enroller_id)
      assert_not_nil(kase)
      assert_equal(kase.status, :submitted)
    end

    test "can't find a non-submitted case for an enroller" do
      case_repo = Case::Repo.new
      case_rec = cases(:opened_1)

      assert_raises(ActiveRecord::RecordNotFound) do
        case_repo.find_for_enroller(case_rec.id, case_rec.enroller_id)
      end
    end

    test "can't find another enroller's case" do
      case_repo = Case::Repo.new
      case_rec1 = cases(:submitted_1)
      case_rec2 = cases(:submitted_2)

      assert_raises(ActiveRecord::RecordNotFound) do
        case_repo.find_for_enroller(case_rec1.id, case_rec2.enroller_id)
      end
    end

    test "finds an opened case by id" do
      case_repo = Case::Repo.new
      case_rec = cases(:opened_1)

      kase = case_repo.find_opened(case_rec.id)
      assert_not_nil(kase)
      assert_equal(kase.status, :opened)
    end

    test "can't find an opened case by id" do
      case_repo = Case::Repo.new
      case_rec = cases(:submitted_1)

      assert_raises(ActiveRecord::RecordNotFound) do
        case_repo.find_opened(case_rec.id)
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
      cases = case_repo.find_all_opened
      assert_length(cases, 4)
    end

    test "saves an opened case" do
      event_queue = EventQueue.new

      case_repo = Case::Repo.new(
        event_queue: event_queue
      )

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
          arrears: "$1000"
        ),
        enroller: Enroller::Repo.map_record(enrollers(:enroller_1)),
        supplier: Supplier::Repo.map_record(suppliers(:supplier_1))
      )

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
      assert_not_nil(kase.recipient.id)

      assert_length(kase.events, 0)
      assert_length(event_queue, 1)
    end

    test "saves an opened case for an existing recipient" do
      event_queue = EventQueue.new
      case_repo = Case::Repo.new(
        event_queue: event_queue
      )

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
          arrears: "$1000"
        ),
        enroller: Enroller::Repo.map_record(enrollers(:enroller_1)),
        supplier: Supplier::Repo.map_record(suppliers(:supplier_1))
      )

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
      assert_not_nil(kase.recipient.id)

      assert_length(kase.events, 0)
      assert_length(event_queue, 1)
    end

    test "saves a dhs account" do
      kase = Case::Repo.map_record(cases(:opened_1))
      kase.attach_dhs_account(
        Recipient::DhsAccount.new(
          number: "11111",
          household: Recipient::Household.new(
            size: "3",
            income: "$999"
          )
        )
      )

      case_repo = Case::Repo.new
      case_repo.save_dhs_account(kase)

      case_rec = kase.record
      assert_equal(case_rec.status, "pending")

      recipient_rec = case_rec.recipient
      assert_equal(recipient_rec.dhs_number, "11111")
      assert_equal(recipient_rec.household_size, "3")
      assert_equal(recipient_rec.household_income, "$999")
    end

    test "saves all fields" do
      case_rec = cases(:pending_2)
      account = Recipient::DhsAccount.new(
        number: "11111",
        household: Recipient::Household.new(size: "3", income: "$999")
      )

      kase = Case::Repo.map_record(case_rec)
      kase.attach_dhs_account(account)
      kase.submit

      case_repo = Case::Repo.new
      case_repo.save(kase)

      case_rec = kase.record
      assert_equal(case_rec.status, "submitted")

      recipient_rec = case_rec.recipient
      assert_equal(recipient_rec.dhs_number, "11111")
      assert_equal(recipient_rec.household_size, "3")
      assert_equal(recipient_rec.household_income, "$999")
    end

    test "maps a record" do
      case_rec = cases(:submitted_1)

      kase = Case::Repo.map_record(case_rec)
      assert_not_nil(kase.record)
      assert_not_nil(kase.id.val)
      assert_not_nil(kase.status)
      assert_not_nil(kase.supplier_id)
      assert_not_nil(kase.enroller_id)
      assert_not_nil(kase.account)
      assert_not_nil(kase.recipient)

      recipient = kase.recipient
      assert_not_nil(recipient.record)
      assert_not_nil(recipient.id)
      assert_not_nil(recipient.profile)
      assert_not_nil(recipient.dhs_account)
    end
  end
end
