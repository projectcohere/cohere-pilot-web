require "test_helper"

class CaseActivityTests < ActionCable::Channel::TestCase
  tests(Cases::ActivityChannel)

  # -- tests --
  test "subscribe a user to their partner's case activity" do
    user_rec = users(:cohere_1)
    user = User::Repo.map_record(user_rec)
    stub_connection(user: user)

    subscribe
    assert_has_stream_for(user_rec.partner_id)
  end
end
