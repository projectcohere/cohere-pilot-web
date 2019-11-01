require "test_helper"
require "minitest/mock"

class Case
  module Notes
    class NewCaseTests < ActiveSupport::TestCase
      test "has all message data" do
        kase = Case.new(id: 1, recipient: nil, supplier: nil, enroller: nil, status: nil, updated_at: nil, completed_at: nil)
        cases = Minitest::Mock.new
          .expect(:find_one, kase, [1])

        user = User.new(id: 2, email: nil, role: nil)
        users = Minitest::Mock.new
          .expect(:find_one, user, [2])

        note = NewCase.new(1, 2, users: users, cases: cases)
        assert_match(/new case/, note.title)
        assert_equal(note.case, kase)
        assert_equal(note.receiver, user)
      end

      test "broadcasts to many users" do
        users = Minitest::Mock.new
          .expect(:find_for_new_case_notification, [
            User.new(id: 1, email: nil, role: nil),
            User.new(id: 2, email: nil, role: nil)
          ])

        broadcast = NewCase::Broadcast.new(users: users)
        assert_equal(broadcast.receiver_ids, [1, 2])
      end
    end
  end
end
