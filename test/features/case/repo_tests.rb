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

    test "finds a submitted case by id for an enroller" do
      repo = Case::Repo.new
      record = cases(:submitted_1)
      kase = repo.find_one_for_enroller(record.id, record.enroller_id)
      assert_not_nil(kase)
      assert_equal(kase.status, :submitted)
    end

    test "can't find a non-submitted case for an enroller" do
      repo = Case::Repo.new
      record = cases(:opened_1)

      assert_raises(ActiveRecord::RecordNotFound) do
        repo.find_one_for_enroller(record.id, record.enroller_id)
      end
    end

    test "can't find another enroller's case" do
      repo = Case::Repo.new
      record1 = cases(:submitted_1)
      record2 = cases(:submitted_2)
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
      record = cases(:submitted_1)

      assert_raises(ActiveRecord::RecordNotFound) do
        repo.find_one_opened(record.id)
      end
    end

    test "finds all incomplete cases" do
      repo = Case::Repo.new
      cases = repo.find_incomplete
      assert_length(cases, 6)
    end

    test "finds all submitted cases for an enroller" do
      repo = Case::Repo.new
      enroller_id = cases(:submitted_1).enroller_id
      cases = repo.find_for_enroller(enroller_id)
      assert_length(cases, 2)
    end

    test "finds all opened cases" do
      repo = Case::Repo.new
      cases = repo.find_opened
      assert_length(cases, 4)
    end
  end
end
