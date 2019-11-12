require "test_helper"
require "minitest/mock"

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
      case_repo = Minitest::Mock.new
        .expect(:save, nil, [kase])

      form_attrs = {
        "first_name" => "Edith"
      }

      form = Form.new(
        kase,
        form_attrs,
        case_repo: case_repo
      )

      did_save = form.save
      assert(did_save)
      assert_equal(kase.recipient.profile.name.first, "Edith")
    end

    test "does not save an invalid case" do
      kase = Case::Repo.map_record(cases(:pending_1))
      form = Form.new(kase, {
        "first_name" => ""
      })

      did_save = form.save
      assert_not(did_save)
      assert_present(form.errors[:first_name])
    end

    test "submits a case" do
      kase = Case::Repo.map_record(cases(:pending_1))
      case_repo = Minitest::Mock.new
        .expect(:save, nil, [kase])

      form_attrs = {
        "status" => "submitted"
      }

      form = Form.new(
        kase,
        form_attrs,
        case_repo: case_repo
      )

      did_save = form.save
      assert(did_save)
      assert_equal(kase.status, :submitted)
    end

    test "does not submit an invalid case" do
      kase = Case::Repo.map_record(cases(:pending_1))
      form = Form.new(kase, {
        "status" => "submitted",
        "dhs_number" => nil
      })

      did_save = form.save
      assert_not(did_save)
      assert_present(form.errors)
      assert_present(form.errors[:dhs_number])
    end
  end
end
