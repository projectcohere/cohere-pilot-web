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

    test "find cohere and governor users for an opened case" do
      user_repo = User::Repo.new

      emails = user_repo.find_emails_for_opened_case
      assert_length(emails, 2)
      assert_all(emails, ->(e) { e.ends_with?("@projectcohere.com") || e.ends_with?("@michigan.gov") })
    end

    test "find authorized enrollers for a submitted case" do
      user_repo = User::Repo.new
      case_rec = cases(:submitted_1)
      kase = Case::Repo.map_record(case_rec)

      emails = user_repo.find_emails_for_submitted_case(kase)
      assert_length(emails, 1)
      assert_all(emails, ->(e) { e.ends_with?("@testmetro.org") })
    end

    test "find cohere users for a completed case" do
      user_repo = User::Repo.new

      emails = user_repo.find_emails_for_completed_case
      assert_length(emails, 1)
      assert_all(emails, ->(e) { e.ends_with?("@projectcohere.com") })
    end

    # -- commands --
    test "signs in the current user" do
      user_repo = User::Repo.new
      user_rec = users(:cohere_1)

      user_repo.sign_in(user_rec)
      assert_equal(user_repo.find_current.id.val, user_rec.id)
    end

    test "save an invited user" do
      user_repo = User::Repo.new
      user_partner_rec = partners(:cohere_1)
      user = User.invite(User::Invitation.new(
        email: "test@website.com",
        partner_id: user_partner_rec.id,
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
