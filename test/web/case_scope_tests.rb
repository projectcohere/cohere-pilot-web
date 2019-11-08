require "test_helper"

class CaseScopeTests < ActiveSupport::TestCase
  test "permits matched url and user scopes" do
    user = User.new(id: nil, email: nil, role: User::Role.named(:dhs))
    scope = CaseScope.new("/cases/dhs/1/edit", user)
    assert(scope.permit?)
  end

  test "rejects unmatched url and user scopes" do
    user = User.new(id: nil, email: nil, role: User::Role.named(:cohere))
    scope = CaseScope.new("/cases/dhs/1", user)
    assert(scope.reject?)
  end

  test "rewrites paths with no path" do
    user = User.new(id: nil, email: nil, role: User::Role.named(:dhs))
    scope = CaseScope.new(nil, user)
    scoped = scope.rewrite_path("/cases?test=1")
    assert_equal(scoped, "/cases/dhs?test=1")
  end

  test "rewrites paths from a non-case path" do
    user = User.new(id: nil, email: nil, role: User::Role.named(:dhs))
    scope = CaseScope.new("/sessions", user)
    scoped = scope.rewrite_path("/cases?test=1")
    assert_equal(scoped, "/cases/dhs?test=1")
  end

  test "rewrites scoped paths to the user's scope" do
    user = User.new(id: nil, email: nil, role: User::Role.named(:dhs))
    scope = CaseScope.new("/cases/supplier/1", user)
    scoped = scope.rewrite_path("/cases/supplier/1")
    assert_equal(scoped, "/cases/dhs/1")
  end

  test "rewrites scoped paths to a root user's scope" do
    user = User.new(id: nil, email: nil, role: User::Role.named(:cohere))
    scope = CaseScope.new("/cases/enroller/1", user)
    scoped = scope.rewrite_path("/cases/enroller/1")
    assert_equal(scoped, "/cases/1")
  end
end
