require "test_helper"

class UserTests < ActiveSupport::TestCase
  test "can be constructed from a operator record" do
    user = User::Repo.map_record(users(:cohere_1))
    assert_equal(user.email, "me@cohere.org")
    assert_equal(user.role, :cohere)
  end

  test "can be constructed from an enroller record" do
    user = User::Repo.map_record(users(:enroller_1))
    assert_equal(user.email, "me@testmetro.org")
    assert_equal(user.role, :enroller)
    assert_not_nil(user.organization)
  end

  test "can be constructed from a supplier record" do
    user = User::Repo.map_record(users(:supplier_1))
    assert_equal(user.email, "me@testenergy.com")
    assert_equal(user.role, :supplier)
    assert_not_nil(user.organization)
  end

  test "can be constructed from a dhs partner record" do
    user = User::Repo.map_record(users(:dhs_1))
    assert_equal(user.email, "me@michigan.gov")
    assert_equal(user.role, :dhs)
  end
end
