require "test_helper"

class User
  class RepoTests < ActiveSupport::TestCase
    test "maps a user record" do
      user_rec = users(:agent_1)
      user_rec.confirmation_token = "test-token"

      user = User::Repo.map_record(user_rec)
      assert_not_nil(user.id.val)
      assert_equal(user.email, "me@projectcohere.com")
      assert(user.role.agent?)
      assert_not_nil(user.partner)
      assert_equal(user.confirmation_token, "test-token")
    end

    test "maps an agent user record" do
      user_rec = users(:agent_1)

      user = User::Repo.map_record(user_rec)
      assert(user.role.agent?)
      assert_equal(user.partner.membership, Partner::Membership::Cohere)
    end

    test "maps an enroller user record" do
      user_rec = users(:enroller_1)

      user = User::Repo.map_record(user_rec)
      assert(user.role.enroller?)
      assert_equal(user.partner.membership, Partner::Membership::Enroller)
    end

    test "maps a source user record" do
      user_rec = users(:source_1)

      user = User::Repo.map_record(user_rec)
      assert(user.role.source?)
      assert_equal(user.partner.membership, Partner::Membership::Supplier)
    end

    test "maps a governor user record" do
      user_rec = users(:governor_1)

      user = User::Repo.map_record(user_rec)
      assert(user.role.governor?)
      assert_equal(user.partner.membership, Partner::Membership::Governor)
    end
  end
end
