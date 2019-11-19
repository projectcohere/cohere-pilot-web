require "test_helper"

class User
  class RecordTests < ActiveSupport::TestCase
    test "password must be at least 12 characters with 1 number and 1 symbol" do
      user_rec = User::Record.new(
        email: "a@b.cd"
      )

      user_rec.password = "passwordddd"
      assert_not(user_rec.valid?)

      user_rec.password = "passworddddd"
      assert_not(user_rec.valid?)

      user_rec.password = "password1234"
      assert_not(user_rec.valid?)

      user_rec.password = "password123$"
      assert(user_rec.valid?)

      user_rec.password = "password!234"
      assert(user_rec.valid?)
    end
  end
end
