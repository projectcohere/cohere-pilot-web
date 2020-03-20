require "test_helper"

class User
  class RecordTests < ActiveSupport::TestCase
    test "password must be at least 12 characters with 1 number and 1 symbol" do
      user_rec = User::Record.new(
        email: "a@b.cd",
      )

      user_rec.password = "passwordddd"
      user_rec.validate
      assert_present(user_rec.errors[:password])

      user_rec.password = "passworddddd"
      user_rec.validate
      assert_present(user_rec.errors[:password])

      user_rec.password = "password1234"
      user_rec.validate
      assert_present(user_rec.errors[:password])

      user_rec.password = "password123$"
      user_rec.validate
      assert_blank(user_rec.errors[:password])

      user_rec.password = "password!234"
      user_rec.validate
      assert_blank(user_rec.errors[:password])
    end
  end
end
