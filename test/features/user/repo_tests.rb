require "test_helper"

class User
  class RepoTests < ActiveSupport::TestCase
    test "finds cohere and dhs users for a new case" do
      repo = User::Repo.new
      users = repo.find_opened_case_contributors
      assert_length(users, 2)
      assert_all(users.map(&:role), ->(r) { r == :cohere || r == :dhs })
    end

    test "finds enrollers for a submitted case" do
      enroller = Enroller::Repo.map_record(enrollers(:enroller_1))
      repo = User::Repo.new
      users = repo.find_submitted_case_contributors(enroller.id)
      assert_length(users, 1)
      assert_all(users, ->(e) { e.organization == enroller })
    end
  end
end
