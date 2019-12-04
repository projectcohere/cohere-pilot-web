require "test_helper"
require "minitest/mock"

module Cases
  class FormTests < ActiveSupport::TestCase
    test "can be initialized from a case" do
      case_rec = cases(:pending_1)
      kase = Case::Repo.map_record(case_rec, case_rec.documents)

      form = Form.new(kase)
      assert_present(form.dhs_number)
      assert_present(form.first_name)
      assert_present(form.phone_number)
      assert_present(form.street)
      assert_present(form.account_number)
      assert_present(form.dhs_number)
      assert_present(form.income)
      assert(form.signed_contract)
    end

    test "saves a case" do
      kase = Case::Repo.map_record(cases(:pending_1))
      case_repo = Minitest::Mock.new
        .expect(:save_all_fields_and_new_documents, nil, [kase])

      form_attrs = {
        "first_name" => "Edith"
      }

      form = Form.new(
        kase,
        form_attrs,
        case_repo: case_repo
      )

      did_save = form.save
      assert(did_save, "expected no errors saving, but got #{form.errors.full_messages}")
      assert_equal(kase.recipient.profile.name.first, "Edith")
    end

    test "does not save an invalid case" do
      kase = Case::Repo.map_record(cases(:pending_1))
      form = Form.new(kase, {
        "first_name" => ""
      })

      did_save = form.save
      assert_not(did_save, "expected errors saving, but got none")
      assert_present(form.errors[:first_name])
    end

    test "submits a case" do
      case_rec = cases(:pending_1)
      kase = Case::Repo.map_record(case_rec, case_rec.documents)
      case_repo = Minitest::Mock.new
        .expect(:save_all_fields_and_new_documents, nil, [kase])

      form_attrs = {
        "status" => "submitted"
      }

      form = Form.new(
        kase,
        form_attrs,
        case_repo: case_repo
      )

      did_save = form.save
      assert(did_save, "expected no errors saving, but got #{form.errors.full_messages}")
      assert_equal(kase.status, Case::Status::Submitted)
    end

    test "does not submit an invalid case" do
      case_rec = cases(:pending_1)
      kase = Case::Repo.map_record(case_rec, case_rec.documents)
      form = Form.new(kase, {
        "status" => "submitted",
        "dhs_number" => nil
      })

      did_save = form.save
      assert_not(did_save, "expected errors saving, but got none")
      assert_present(form.errors[:dhs_number])
    end

    test "completes a case" do
      case_rec = cases(:submitted_1)
      kase = Case::Repo.map_record(case_rec, case_rec.documents)
      case_repo = Minitest::Mock.new
        .expect(:save_all_fields_and_new_documents, nil, [kase])

      form_attrs = {
        "status" => "approved"
      }

      form = Form.new(
        kase,
        form_attrs,
        case_repo: case_repo
      )

      did_save = form.save
      assert(did_save, "expected no errors saving, but got #{form.errors.full_messages}")
      assert_equal(kase.status, Case::Status::Approved)
      assert_not_nil(kase.completed_at)
    end

    test "creates a signed contract for a case" do
      kase = Case::Repo.map_record(cases(:pending_1))
      case_repo = Minitest::Mock.new
        .expect(:save_all_fields_and_new_documents, nil, [kase])

      form_attrs = {
        "signed_contract" => true
      }

      form = Form.new(
        kase,
        form_attrs,
        case_repo: case_repo
      )

      did_save = form.save
      assert(did_save, "expected no errors saving, but got #{form.errors.full_messages}")
      assert_length(kase.new_documents, 1)
    end
  end
end
