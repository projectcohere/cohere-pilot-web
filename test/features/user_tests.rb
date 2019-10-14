class UserTests < ActiveSupport::TestCase
  test "an operator can be constructed from a record" do
    user = User.from_record(users(:cohere_1))
    assert_equal(user.role, :cohere)
  end

  test "an enroller can be constructed from a record" do
    user = User.from_record(users(:enroller_1))
    assert_equal(user.role, :enroller)
    assert_not_nil(user.organization)
  end

  test "a supplier can be constructed from a record" do
    user = User.from_record(users(:supplier_1))
    assert_equal(user.role, :supplier)
    assert_not_nil(user.organization)
  end
end
