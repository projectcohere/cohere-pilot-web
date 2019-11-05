require "test_helper"
require "minitest/mock"

class Case
  module Notes
    class SubmittedCaseTests < ActiveSupport::TestCase
      test "has all message data" do
        kase = Case.new(id: 1, recipient: nil, supplier: nil, enroller: nil, status: nil, updated_at: nil, completed_at: nil)
        cases = Minitest::Mock.new
          .expect(:find_one, kase, [1])

        user = User.new(id: 2, email: nil, role: nil)
        users = Minitest::Mock.new
          .expect(:find_one, user, [2])

        note = SubmittedCase.new(1, 2, users: users, cases: cases)
        assert_match(/submitted/, note.title)
        assert_equal(note.case, kase)
        assert_equal(note.receiver, user)
      end

      test "broadcasts to many users" do
        users = Minitest::Mock.new
          .expect(:find_submitted_case_contributors, [
            User.new(id: 2, email: nil, role: nil),
          ])

        broadcast = SubmittedCase::Broadcast.new(users: users)
        assert_equal(broadcast.receiver_ids, [2])
      end
    end
  end
end
