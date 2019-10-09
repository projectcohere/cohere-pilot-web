require 'test_helper'

class Case
  class RepoTests < ActiveSupport::TestCase
    test "it finds all incomplete cases" do
      repo = Case::Repo.new
      cases = repo.find_incomplete
      assert_length(cases, 2)
      assert_all(cases, ->(c) { c.incomplete? })
    end
  end
end
