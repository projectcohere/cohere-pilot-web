require "test_helper"
require "minitest/mock"

class Case
  class RepoTests < ActiveSupport::TestCase
    test "finds a case by id" do
      repo = Case::Repo.new
      kase_rec = cases(:approved_1)
      kase = repo.find(kase_rec.id)
      assert_not_nil(kase)
    end

    test "finds a case by phone number" do
      record = recipients(:recipient_1)
      repo = Case::Repo.new
      kase = repo.find_by_phone_number(record.phone_number)
      assert_not_nil(kase)
      assert_equal(kase.recipient.profile.phone.number, record.phone_number)
    end

    test "can't find a case with an unknown id" do
      repo = Case::Repo.new
      assert_raises(ActiveRecord::RecordNotFound) do
        kase = repo.find(1)
      end
    end

    test "finds a submitted case by id for an enroller" do
      repo = Case::Repo.new
      record = cases(:submitted_1)
      kase = repo.find_for_enroller(record.id, record.enroller_id)
      assert_not_nil(kase)
      assert_equal(kase.status, :submitted)
    end

    test "can't find a non-submitted case for an enroller" do
      repo = Case::Repo.new
      record = cases(:opened_1)

      assert_raises(ActiveRecord::RecordNotFound) do
        repo.find_for_enroller(record.id, record.enroller_id)
      end
    end

    test "can't find another enroller's case" do
      repo = Case::Repo.new
      record1 = cases(:submitted_1)
      record2 = cases(:submitted_2)
      assert_raises(ActiveRecord::RecordNotFound) do
        repo.find_for_enroller(record1.id, record2.enroller_id)
      end
    end

    test "finds an opened case by id" do
      repo = Case::Repo.new
      record = cases(:opened_1)
      kase = repo.find_opened(record.id)
      assert_not_nil(kase)
      assert_equal(kase.status, :opened)
    end

    test "can't find an opened case by id" do
      repo = Case::Repo.new
      record = cases(:submitted_1)

      assert_raises(ActiveRecord::RecordNotFound) do
        repo.find_opened(record.id)
      end
    end

    test "finds all incomplete cases" do
      repo = Case::Repo.new
      cases = repo.find_all_incomplete
      assert_length(cases, 6)
    end

    test "finds all submitted cases for an enroller" do
      repo = Case::Repo.new
      enroller_id = cases(:submitted_1).enroller_id
      cases = repo.find_all_for_enroller(enroller_id)
      assert_length(cases, 2)
    end

    test "finds all opened cases" do
      repo = Case::Repo.new
      cases = repo.find_all_opened
      assert_length(cases, 4)
    end

    test "saves an opened case" do
      repo_events = ::Events.new
      repo = Case::Repo.new(
        events: repo_events
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
        repo.save_opened(kase)
      end

      assert_difference(
        -> { Case::Record.count } => 1,
        -> { Recipient::Record.count } => 1,
      ) do
        act.()

        assert_not_nil(kase.record)
        assert_not_nil(kase.id.val)
        assert_not_nil(kase.recipient.record)
        assert_not_nil(kase.recipient.id)

        assert_length(kase.events, 0)
        assert_length(repo_events, 1)
      end
    end

    test "saves an opened case for an existing recipient" do
      repo_events = ::Events.new
      repo = Case::Repo.new(
        events: repo_events
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
        repo.save_opened(kase)
      end

      assert_difference(
        -> { Case::Record.count } => 1,
        -> { Recipient::Record.count } => 0,
      ) do
        act.()

        assert_not_nil(kase.record)
        assert_not_nil(kase.id.val)
        assert_not_nil(kase.recipient.record)
        assert_not_nil(kase.recipient.id)

        assert_length(kase.events, 0)
        assert_length(repo_events, 1)
      end
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

      repo = Case::Repo.new
      repo.save_dhs_account(kase)

      record = kase.record
      assert_equal(record.status, "pending")

      record = kase.record.recipient
      assert_equal(record.dhs_number, "11111")
      assert_equal(record.household_size, "3")
      assert_equal(record.household_income, "$999")
    end

    test "saves all fields" do
      kase = Case::Repo.map_record(cases(:pending_2))
      kase.attach_dhs_account(Recipient::DhsAccount.new(
        number: "11111",
        household: Recipient::Household.new(size: "3", income: "$999")
      ))
      kase.submit

      repo = Case::Repo.new
      repo.save(kase)

      record = kase.record
      assert_equal(record.status, "submitted")

      record = record.recipient
      assert_equal(record.dhs_number, "11111")
      assert_equal(record.household_size, "3")
      assert_equal(record.household_income, "$999")
    end

    test "maps a record" do
      kase = Case::Repo.map_record(cases(:submitted_1))
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
