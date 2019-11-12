require "test_helper"

class User
  class RepoTests < ActiveSupport::TestCase
    test "maps a operator record" do
      user_rec = users(:cohere_1)
      user_rec.confirmation_token = "test-token"

      user = User::Repo.map_record(user_rec)
      assert_equal(user.email, "me@cohere.org")
      assert_equal(user.role.name, :cohere)
      assert_equal(user.confirmation_token, "test-token")
    end

    test "maps an enroller record" do
      user_rec = users(:enroller_1)

      user = User::Repo.map_record(user_rec)
      assert_equal(user.email, "me@testmetro.org")
      assert_equal(user.role.name, :enroller)
      assert_not_nil(user.role.organization_id)
    end

    test "maps a supplier record" do
      user_rec = users(:supplier_1)

      user = User::Repo.map_record(user_rec)
      assert_equal(user.email, "me@testenergy.com")
      assert_equal(user.role.name, :supplier)
      assert_not_nil(user.role.organization_id)
    end

    test "maps a dhs partner record" do
      user_rec = users(:dhs_1)

      user = User::Repo.map_record(user_rec)
      assert_equal(user.email, "me@michigan.gov")
      assert_equal(user.role.name, :dhs)
    end
  end
end
