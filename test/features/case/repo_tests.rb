require 'test_helper'

class Case
  class RepoTests < ActiveSupport::TestCase
    test "finds all incomplete cases" do
      repo = Case::Repo.new
      cases = repo.find_incomplete
      assert_length(cases, 4)
      assert_all(cases, ->(c) { c.incomplete? })
    end

    test "finds all pending cases for an enroller" do
      repo = Case::Repo.new
      enroller_id = cases(:incomplete_2).enroller_id
      cases = repo.find_pending_for_enroller(enroller_id)
      assert_length(cases, 1)
    end
  end
end
