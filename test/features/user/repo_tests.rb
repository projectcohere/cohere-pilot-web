require "test_helper"

class User
  class RepoTests < ActiveSupport::TestCase
    test "finds cohere and dhs users for a new case" do
      repo = User::Repo.new
      users = repo.find_all_opened_case_contributors
      assert_length(users, 2)
      assert_all(users.map(&:role), ->(r) { r == :cohere || r == :dhs })
    end

    test "finds enrollers for a submitted case" do
      enroller = Enroller::Repo.map_record(enrollers(:enroller_1))
      repo = User::Repo.new
      users = repo.find_all_submitted_case_contributors(enroller.id)
      assert_length(users, 1)
      assert_all(users, ->(e) { e.organization == enroller })
    end

    test "maps a operator record" do
      user = User::Repo.map_record(users(:cohere_1))
      assert_equal(user.email, "me@cohere.org")
      assert_equal(user.role, :cohere)
    end

    test "maps an enroller record" do
      user = User::Repo.map_record(users(:enroller_1))
      assert_equal(user.email, "me@testmetro.org")
      assert_equal(user.role, :enroller)
      assert_not_nil(user.organization)
    end

    test "maps a supplier record" do
      user = User::Repo.map_record(users(:supplier_1))
      assert_equal(user.email, "me@testenergy.com")
      assert_equal(user.role, :supplier)
      assert_not_nil(user.organization)
    end

    test "maps a dhs partner record" do
      user = User::Repo.map_record(users(:dhs_1))
      assert_equal(user.email, "me@michigan.gov")
      assert_equal(user.role, :dhs)
    end
  end
end
