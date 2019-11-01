require "test_helper"

class CaseScopeTests < ActiveSupport::TestCase
  test "scopes paths by user scope" do
    user = User.new(id: nil, email: nil, role: :dhs)
    scope = CaseScope.new(:root, user)
    scoped = scope.scoped_path("/cases/1")
    assert_equal(scoped, "/cases/opened/1")
  end

  test "does not scope paths for root-scoped users" do
    user = User.new(id: nil, email: nil, role: :cohere)
    scope = CaseScope.new(:opened, user)
    scoped = scope.scoped_path("/cases/1")
    assert_equal(scoped, "/cases/1")
  end
end
