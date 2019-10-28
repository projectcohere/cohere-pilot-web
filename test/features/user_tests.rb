require "test_helper"

class UserTests < ActiveSupport::TestCase
  test "can be constructed from a operator record" do
    user = User.from_record(users(:cohere_1))
    assert_equal(user.role, :cohere)
  end

  test "can be constructed from an enroller record" do
    user = User.from_record(users(:enroller_1))
    assert_equal(user.role, :enroller)
    assert_not_nil(user.organization)
  end

  test "can be constructed from a supplier record" do
    user = User.from_record(users(:supplier_1))
    assert_equal(user.role, :supplier)
    assert_not_nil(user.organization)
  end

  test "can be constructed from a dhs partner record" do
    user = User.from_record(users(:dhs_1))
    assert_equal(user.role, :dhs)
  end
end
