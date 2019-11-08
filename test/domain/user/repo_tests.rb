require "test_helper"

class User
  class RepoTests < ActiveSupport::TestCase
    # -- queries --
    test "finds cohere and dhs users for a new case" do
      user_repo = User::Repo.new

      users = user_repo.find_all_for_opened_case
      assert_length(users, 2)
      assert_all(users.map(&:role_name), ->(r) { r == :cohere || r == :dhs })
    end

    test "finds matching enrollers for a submitted case" do
      enroller_rec = enrollers(:enroller_1)
      kase = Case.new(enroller_id: enroller_rec.id, status: nil, account: nil, recipient: nil, supplier_id: nil)
      user_repo = User::Repo.new

      users = user_repo.find_all_for_submitted_case(kase)
      assert_length(users, 1)
      assert_all(users, ->(u) { u.role.organization_id == kase.enroller_id })
    end

    # -- commands --
    test "saves an invited user" do
      event_queue = EventQueue.new
      user_repo = User::Repo.new(
        event_queue: event_queue
      )

      user = User.invite("test@website.com",
        role: Role.named(:cohere)
      )

      act = -> do
        user_repo.save_invited(user)
      end

      assert_difference(
        -> { User::Record.count } => 1,
        &act
      )

      assert_not_nil(user.id.val)
      assert_not_nil(user.record)
      assert_not_nil(user.record.confirmation_token)

      assert_length(user.events, 0)
      assert_length(event_queue, 1)
    end

    test "saves an invited org user" do
      enroller_rec = enrollers(:enroller_1)
      enroller_id = enroller_rec.id

      user_repo = User::Repo.new
      user = User.invite("test@enroller.com",
        role: Role.new(
          name: :enroller,
          organization_id: enroller_id
        )
      )

      user_repo.save_invited(user)
      assert_equal(user.record.organization, enroller_rec)
    end

    # -- factories --
    test "maps a operator record" do
      user_rec = users(:cohere_1)

      user = User::Repo.map_record(user_rec)
      assert_equal(user.email, "me@cohere.org")
      assert_equal(user.role.name, :cohere)
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
