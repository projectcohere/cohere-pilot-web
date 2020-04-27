require "test_helper"

class UserTests < ActiveSupport::TestCase
  test "invites a user" do
    user_invitation = User::Invitation.new(
      email: "test@email.com",
      partner_id: 1,
      role: Role::Agent,
    )

    user = User.invite(user_invitation)
    assert_equal(user.id, Id::None)
    assert_equal(user.email, "test@email.com")
    assert_equal(user.role, Role::Agent)
    assert_equal(user.partner_id, 1)

    assert_length(user.events, 1)
    assert_instance_of(User::Events::DidInvite, user.events[0])
  end
end
