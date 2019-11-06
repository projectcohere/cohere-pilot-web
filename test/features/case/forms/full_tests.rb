require "test_helper"

class Case
  module Forms
    class FullTests < ActiveSupport::TestCase
      test "can be initialized from a case" do
        kase = Case::Repo.map_record(cases(:pending_1))

        form = Full.new(kase)
        assert_present(form.dhs_number)
        assert_present(form.first_name)
        assert_present(form.phone_number)
        assert_present(form.street)
        assert_present(form.account_number)
        assert_present(form.dhs_number)
        assert_present(form.income)
      end

      test "saves a case" do
        kase = Case::Repo.map_record(cases(:pending_1))
        form = Full.new(kase)
        form.first_name = "Edith"

        did_save = form.save
        assert(did_save)

        record = kase.recipient.record
        assert_equal(record.first_name, "Edith")
      end

      test "does not save an invalid case" do
        kase = Case::Repo.map_record(cases(:pending_1))
        form = Full.new(kase)
        form.first_name = ""

        did_save = form.save
        assert_not(did_save)
        assert_present(form.errors[:first_name])
      end

      test "saves a submitted case" do
        kase = Case::Repo.map_record(cases(:pending_1))
        form = Full.new(kase)
        form.status = "submitted"

        did_save = form.save
        assert(did_save)

        record = kase.record
        assert(record.submitted?)
      end

      test "does not save an invalid submitted case" do
        kase = Case::Repo.map_record(cases(:pending_1))
        form = Full.new(kase)
        form.status = "submitted"
        form.dhs_number = nil

        did_save = form.save
        assert_not(did_save)
        assert_present(form.errors)
        assert_present(form.errors[:dhs_number])
      end
    end
  end
end
