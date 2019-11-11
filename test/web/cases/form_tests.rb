require "test_helper"

module Cases
  class FormTests < ActiveSupport::TestCase
    test "can be initialized from a case" do
      kase = Case::Repo.map_record(cases(:pending_1))

      form = Form.new(kase)
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
      form = Form.new(kase)
      form.first_name = "Edith"

      did_save = form.save
      assert(did_save)

      record = kase.recipient.record
      assert_equal(record.first_name, "Edith")
    end

    test "does not save an invalid case" do
      kase = Case::Repo.map_record(cases(:pending_1))
      form = Form.new(kase)
      form.first_name = ""

      did_save = form.save
      assert_not(did_save)
      assert_present(form.errors[:first_name])
    end

    test "saves a submitted case" do
      kase = Case::Repo.map_record(cases(:pending_1))
      form = Form.new(kase)
      form.status = "submitted"

      did_save = form.save
      assert(did_save)

      record = kase.record
      assert(record.submitted?)
    end

    test "does not save an invalid submitted case" do
      kase = Case::Repo.map_record(cases(:pending_1))
      form = Form.new(kase)
      form.status = "submitted"
      form.dhs_number = nil

      did_save = form.save
      assert_not(did_save)
      assert_present(form.errors)
      assert_present(form.errors[:dhs_number])
    end

    test "has an fpl percentage" do
      kase = Case::Repo.map_record(cases(:pending_1))
      form = Form.new(kase)
      assert_not_nil(form.fpl_percentage)
    end
  end
end
