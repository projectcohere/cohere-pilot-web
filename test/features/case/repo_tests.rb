require "test_helper"

class Case
  class RepoTests < ActiveSupport::TestCase
    test "finds a case by id" do
      repo = Case::Repo.new
      kase_rec = cases(:complete_1)
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
      record = cases(:incomplete_2)
      kase = repo.find_one_for_enroller(record.id, record.enroller_id)
      assert_not_nil(kase)
    end

    test "can't find a non-pending case for an enroller" do
      repo = Case::Repo.new
      record = cases(:incomplete_1)

      assert_raises(ActiveRecord::RecordNotFound) do
        repo.find_one_for_enroller(record.id, record.enroller_id)
      end
    end

    test "can't find another enroller's case" do
      repo = Case::Repo.new
      record1 = cases(:incomplete_2)
      record2 = cases(:incomplete_4)
      assert_raises(ActiveRecord::RecordNotFound) do
        repo.find_one_for_enroller(record1.id, record2.enroller_id)
      end
    end

    test "finds all incomplete cases" do
      repo = Case::Repo.new
      cases = repo.find_incomplete
      assert_length(cases, 4)
      assert_all(cases, ->(c) { c.completed_at == nil })
    end

    test "finds all pending cases for an enroller" do
      repo = Case::Repo.new
      enroller_id = cases(:incomplete_2).enroller_id
      cases = repo.find_for_enroller(enroller_id)
      assert_length(cases, 1)
    end
  end
end
