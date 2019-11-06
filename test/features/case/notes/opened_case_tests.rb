require "test_helper"
require "minitest/mock"

class Case
  module Notes
    class OpenedCaseTests < ActiveSupport::TestCase
      test "has all message data" do
        cases = Minitest::Mock.new
          .expect(
            :find_one,
            Case.new(status: :testing, account: nil, recipient: nil, supplier_id: nil, enroller_id: nil),
            [1]
          )

        users = Minitest::Mock.new
          .expect(
            :find_one,
            User.new(id: nil, email: "test@website.com", role: nil),
            [2]
          )

        note = OpenedCase.new(1, 2, users: users, cases: cases)
        assert_match(/opened/, note.title)
        assert_equal(note.case.status, :testing)
        assert_equal(note.receiver.email, "test@website.com")
      end

      test "broadcasts to many users" do
        users = Minitest::Mock.new
          .expect(
            :find_opened_case_contributors,
            [User.new(id: 2, email: nil, role: nil)]
          )

        broadcast = OpenedCase::Broadcast.new(users: users)
        assert_equal(broadcast.receiver_ids, [2])
      end
    end
  end
end
