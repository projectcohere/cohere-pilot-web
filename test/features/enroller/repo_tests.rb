require "test_helper"

class Enroller
  class RepoTests < ActiveSupport::TestCase
    test "finds the same default enroller" do
      repo = Enroller::Repo.get
      enroller = repo.find_default
      assert_not_nil(enroller)
      assert_equal(enroller, repo.find_default)
    end
  end
end
