require "test_helper"

class User
  class RecordTests < ActiveSupport::TestCase
    test "password must be at least 8 characters with 1 number and 1 symbol" do
      user_rec = User::Record.new(
        email: "a@b.cd"
      )

      user_rec.password = "passwor"
      assert_not(user_rec.valid?)

      user_rec.password = "password"
      assert_not(user_rec.valid?)

      user_rec.password = "passwor1"
      assert_not(user_rec.valid?)

      user_rec.password = "passwo1$"
      assert(user_rec.valid?)

      user_rec.password = "passwo$1"
      assert(user_rec.valid?)
    end
  end
end
