require "test_helper"

class User
  class RepoTests < ActiveSupport::TestCase
    test "finds cohere and dhs users for a new case notification" do
      repo = User::Repo.new
      users = repo.find_for_new_case_notification
      assert_length(users, 2)
      assert_all(users.map(&:role), ->(r) { r == :cohere || r == :dhs })
    end
  end
end
