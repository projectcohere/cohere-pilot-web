require "test_helper"

class Case
  # TODO: randomize scope/role pairs for catch-all forbid tests
  class PolicyTests < ActiveSupport::TestCase
    # -- list --
    test "permits cohere users to list cases" do
      user = User.new(id: nil, email: nil, role: User::Role.stub(name: :cohere))
      policy = Case::Policy.new(user)
      assert(policy.permit?(:list))
    end

    test "permits enrollers to list cases" do
      user = User.new(id: nil, email: nil, role: User::Role.stub(name: :enroller))
      policy = Case::Policy.new(user)
      assert(policy.permit?(:list))
    end

    test "permits governor users to list cases" do
      user = User.new(id: nil, email: nil, role: User::Role.stub(name: :mddhs))
      policy = Case::Policy.new(user)
      assert(policy.permit?(:list))
    end

    test "permits suppliers to list cases" do
      user = User.new(id: nil, email: nil, role: User::Role.stub(name: :supplier))
      policy = Case::Policy.new(user)
      assert(policy.permit?(:list))
    end

    # -- show --
    test "permits enrollers to view a case" do
      user = User.new(id: nil, email: nil, role: User::Role.stub(name: :enroller))
      kase = cases(:submitted_1)
      policy = Case::Policy.new(user, kase)
      assert(policy.permit?(:view))
    end

    test "permits cohere users to view a case" do
      user = User.new(id: nil, email: nil, role: User::Role.stub(name: :cohere))
      kase = cases(:opened_1)
      policy = Case::Policy.new(user, kase)
      assert(policy.permit?(:view))
    end

    test "forbids governor users from viewing a case" do
      user = User.new(id: nil, email: nil, role: User::Role.stub(name: :governor))
      kase = cases(:opened_1)
      policy = Case::Policy.new(user, kase)
      assert(policy.forbid?(:view))
    end

    test "forbids suppliers from viewing a case" do
      user = User.new(id: nil, email: nil, role: User::Role.stub(name: :supplier))
      kase = cases(:opened_1)
      policy = Case::Policy.new(user, kase)
      assert(policy.forbid?(:view))
    end

    # -- edit --
    test "permits cohere users to edit a case" do
      user = User.new(id: nil, email: nil, role: User::Role.stub(name: :cohere))
      kase = cases(:opened_1)
      policy = Case::Policy.new(user, kase)
      assert(policy.permit?(:edit))
    end

    test "permits governor users to edit a case" do
      user = User.new(id: nil, email: nil, role: User::Role.stub(name: :governor))
      kase = cases(:opened_1)
      policy = Case::Policy.new(user, kase)
      assert(policy.permit?(:edit))
    end

    test "forbids enrollers from editing a case" do
      user = User.new(id: nil, email: nil, role: User::Role.stub(name: :enroller))
      kase = cases(:submitted_1)
      policy = Case::Policy.new(user, kase)
      assert(policy.forbid?(:edit))
    end

    test "forbids suppliers from editing a case" do
      user = User.new(id: nil, email: nil, role: User::Role.stub(name: :supplier))
      kase = cases(:opened_1)
      policy = Case::Policy.new(user, kase)
      assert(policy.forbid?(:edit))
    end

    # -- create --
    test "permits suppliers to create cases" do
      user = User.new(id: nil, email: nil, role: User::Role.stub(name: :supplier))
      policy = Case::Policy.new(user)
      assert(policy.permit?(:create))
    end

    test "forbids others from creating cases" do
      user = User.new(id: nil, email: nil, role: User::Role.stub(name: :cohere))
      policy = Case::Policy.new(user)
      assert(policy.forbid?(:create))
    end
  end
end
