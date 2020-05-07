require "test_helper"

class Case
  # TODO: randomize scope/role pairs for catch-all forbid tests
  class PolicyTests < ActiveSupport::TestCase
    def stub_user(role)
      return User.stub(role: Role.from_key(role))
    end

    # -- list --
    test "permits agents to list cases" do
      user = stub_user(:agent)
      policy = Case::Policy.new(user)
      assert(policy.permit?(:list))
    end

    test "permits enrollers to list cases" do
      user = stub_user(:enroller)
      policy = Case::Policy.new(user)
      assert(policy.permit?(:list))
    end

    test "permits governors users to list cases" do
      user = stub_user(:governor)
      policy = Case::Policy.new(user)
      assert(policy.permit?(:list))
    end

    test "permits sources to list cases" do
      user = stub_user(:source)
      policy = Case::Policy.new(user)
      assert(policy.permit?(:list))
    end

    # -- show --
    test "permits enrollers to view a case" do
      user = stub_user(:enroller)
      kase = cases(:submitted_1)
      policy = Case::Policy.new(user, kase)
      assert(policy.permit?(:view))
    end

    test "permits agents to view a case" do
      user = stub_user(:agent)
      kase = cases(:opened_1)
      policy = Case::Policy.new(user, kase)
      assert(policy.permit?(:view))
    end

    test "forbids governors from viewing a case" do
      user = stub_user(:governor)
      kase = cases(:opened_1)
      policy = Case::Policy.new(user, kase)
      assert(policy.forbid?(:view))
    end

    # -- edit --
    test "permits agents to edit a case" do
      user = stub_user(:agent)
      kase = cases(:opened_1)
      policy = Case::Policy.new(user, kase)
      assert(policy.permit?(:edit))
    end

    test "permits governors to edit a case" do
      user = stub_user(:governor)
      kase = cases(:opened_1)
      policy = Case::Policy.new(user, kase)
      assert(policy.permit?(:edit))
    end

    test "forbids enrollers from editing a case" do
      user = stub_user(:enroller)
      kase = cases(:submitted_1)
      policy = Case::Policy.new(user, kase)
      assert(policy.forbid?(:edit))
    end

    test "forbids suppliers from editing a case" do
      user = stub_user(:source)
      kase = cases(:opened_1)
      policy = Case::Policy.new(user, kase)
      assert(policy.forbid?(:edit))
    end

    # -- create --
    test "permits suppliers to create cases" do
      user = stub_user(:source)
      policy = Case::Policy.new(user)
      assert(policy.permit?(:create))
    end

    test "forbids agents from creating cases" do
      user = stub_user(:agent)
      policy = Case::Policy.new(user)
      assert(policy.forbid?(:create))
    end
  end
end
