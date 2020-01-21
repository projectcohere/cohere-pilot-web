require "test_helper"

module Db
  class UserRepoTests < ActiveSupport::TestCase
    # -- queries --
    test "find a user by remember token" do
      user_repo = User::Repo.new
      user_rec = users(:cohere_1)

      user = user_repo.find_by_remember_token(user_rec.remember_token)
      assert_equal(user.id.val, user_rec.id)
    end

    test "find cohere and dhs users for an opened case" do
      user_repo = User::Repo.new

      users = user_repo.find_all_for_opened_case
      assert_length(users, 2)
      assert_same_elements(users.map(&:role_name), [:cohere, :dhs])
    end

    test "find authorized enrollers for a submitted case" do
      enroller_rec = enrollers(:enroller_1)
      kase = Case.stub(enroller_id: enroller_rec.id)
      user_repo = User::Repo.new

      users = user_repo.find_all_for_submitted_case(kase)
      assert_length(users, 1)
      assert_equal(users[0].role.organization_id, kase.enroller_id)
    end

    test "find cohere users for a completed case" do
      user_repo = User::Repo.new

      users = user_repo.find_all_for_completed_case
      assert_length(users, 1)
      assert_equal(users[0].role_name, :cohere)
    end

    # -- commands --
    test "set the current user" do
      user_repo = User::Repo.new
      user = User.stub(id: Id.new(42))

      user_repo.current = user
      assert_equal(user_repo.find_current, user)
    end

    test "save an invited user" do
      domain_events = ArrayQueue.new

      user_repo = User::Repo.new(
        domain_events: domain_events
      )

      user = User.invite(User::Invitation.new(
        email: "test@website.com",
        role: User::Role.named(:cohere)
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

      assert_length(user.events, 0)
      assert_length(domain_events, 1)
    end

    test "save an invited org user" do
      enroller_rec = enrollers(:enroller_1)
      enroller_id = enroller_rec.id

      user_repo = User::Repo.new
      user = User.invite(User::Invitation.new(
        email: "test@enroller.com",
        role: User::Role.new(
          name: :enroller,
          organization_id: enroller_id
        )
      ))

      user_repo.save_invited(user)
      assert_equal(user.record.organization, enroller_rec)
    end
  end
end
