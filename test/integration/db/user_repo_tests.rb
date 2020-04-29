require "test_helper"

module Db
  class UserRepoTests < ActiveSupport::TestCase
    # -- queries --
    test "find a user by remember token" do
      user_repo = User::Repo.new
      user_rec = users(:agent_1)

      user = user_repo.find_by_remember_token(user_rec.remember_token)
      assert_equal(user.id.val, user_rec.id)
    end

    # -- commands --
    test "signs in the current user" do
      user_repo = User::Repo.new
      user_rec = users(:agent_1)

      user_repo.sign_in(user_rec)
      assert_equal(user_repo.find_current.id.val, user_rec.id)
    end

    test "save an invited user" do
      user_repo = User::Repo.new

      partner_rec = partners(:cohere_1)
      user = User.invite(User::Invitation.new(
        email: "test@website.com",
        role: Role::Agent,
        partner_id: partner_rec.id,
      ))

      act = -> do
        user_repo.save_invited(user)
      end

      assert_difference(
        -> { User::Record.count } => 1,
        &act
      )

      assert_not_nil(user.id.val)
      assert_not_nil(user.confirmation_token)
      assert_not_nil(user.record)

      events = user.events
      assert_length(events, 0)
      assert_length(Events::DispatchAll.get.events, 1)
    end
  end
end
