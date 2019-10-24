require "test_helper"

class Case
  class RepoTests < ActiveSupport::TestCase
    test "finds a case by id" do
      repo = Case::Repo.new
      kase_rec = cases(:approved_1)
      kase = repo.find_one(kase_rec.id)
      assert_not_nil(kase)
    end

    test "can't find a case with an unknown id" do
      repo = Case::Repo.new
      assert_raises(ActiveRecord::RecordNotFound) do
        kase = repo.find_one(1)
      end
    end

    test "finds a pending case by id for an enroller" do
      repo = Case::Repo.new
      record = cases(:pending_1)
      kase = repo.find_one_for_enroller(record.id, record.enroller_id)
      assert_not_nil(kase)
      assert_equal(kase.status, :pending)
    end

    test "can't find a non-pending case for an enroller" do
      repo = Case::Repo.new
      record = cases(:opened_1)

      assert_raises(ActiveRecord::RecordNotFound) do
        repo.find_one_for_enroller(record.id, record.enroller_id)
      end
    end

    test "can't find another enroller's case" do
      repo = Case::Repo.new
      record1 = cases(:pending_1)
      record2 = cases(:pending_2)
      assert_raises(ActiveRecord::RecordNotFound) do
        repo.find_one_for_enroller(record1.id, record2.enroller_id)
      end
    end

    test "finds an opened case by id" do
      repo = Case::Repo.new
      record = cases(:opened_1)
      kase = repo.find_one_opened(record.id)
      assert_not_nil(kase)
      assert_equal(kase.status, :opened)
    end

    test "can't find an opened case by id" do
      repo = Case::Repo.new
      record = cases(:pending_1)

      assert_raises(ActiveRecord::RecordNotFound) do
        repo.find_one_opened(record.id)
      end
    end

    test "finds all incomplete cases" do
      repo = Case::Repo.new
      cases = repo.find_incomplete
      assert_length(cases, 6)
      assert_all(cases, ->(c) { c.completed_at.nil? })
    end

    test "finds all pending cases for an enroller" do
      repo = Case::Repo.new
      enroller_id = cases(:pending_1).enroller_id
      cases = repo.find_for_enroller(enroller_id)
      assert_length(cases, 1)
      assert_all(cases, ->(c) { c.status == :pending })
    end

    test "finds all opened cases" do
      repo = Case::Repo.new
      cases = repo.find_opened
      assert_length(cases, 2)
      assert_all(cases, ->(c) { c.status == :opened })
    end
  end
end
