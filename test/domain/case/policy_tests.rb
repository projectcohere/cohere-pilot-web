require "test_helper"

class Case
  # TODO: randomize scope/role pairs for catch-all forbid tests
  class PolicyTests < ActiveSupport::TestCase
    # -- scopes --
    test "restricts operators to unscoped cases" do
      user = User.new(id: nil, email: nil, role: :cohere)

      policy = Case::Policy.new(user)
      assert(policy.permit?(:some))

      policy = Case::Policy.new(user, scope: :dhs)
      assert(policy.forbid?(:any))
    end

    test "restricts enrollers' cases" do
      user = User.new(id: nil, email: nil, role: :enroller)

      policy = Case::Policy.new(user, scope: :enroller)
      assert(policy.permit?(:some))

      policy = Case::Policy.new(user)
      assert(policy.forbid?(:any))
    end

    test "restricts suppliers' cases" do
      user = User.new(id: nil, email: nil, role: :supplier)

      policy = Case::Policy.new(user, scope: :supplier)
      assert(policy.permit?(:some))

      policy = Case::Policy.new(user)
      assert(policy.forbid?(:any))
    end

    test "restricts dhs partners' cases" do
      user = User.new(id: nil, email: nil, role: :dhs)

      policy = Case::Policy.new(user, scope: :dhs)
      assert(policy.permit?(:some))

      policy = Case::Policy.new(user)
      assert(policy.forbid?(:any))
    end

    # -- list --
    test "permits operators to list cases" do
      user = User.new(id: nil, email: nil, role: :cohere)
      policy = Case::Policy.new(user)
      assert(policy.permit?(:list))
    end

    test "permits enrollers to list cases" do
      user = User.new(id: nil, email: nil, role: :enroller)
      policy = Case::Policy.new(user, scope: :enroller)
      assert(policy.permit?(:list))
    end

    test "permits dhs partners to list cases" do
      user = User.new(id: nil, email: nil, role: :dhs)
      policy = Case::Policy.new(user, scope: :dhs)
      assert(policy.permit?(:list))
    end

    test "permits suppliers to list cases" do
      user = User.new(id: nil, email: nil, role: :supplier)
      policy = Case::Policy.new(user, scope: :supplier)
      assert(policy.permit?(:list))
    end

    # -- show --
    test "permits enrollers to view a case" do
      user = User.new(id: nil, email: nil, role: :enroller)
      kase = cases(:submitted_1)
      policy = Case::Policy.new(user, kase, scope: :enroller)
      assert(policy.permit?(:view))
    end

    test "forbids operators from viewing a case" do
      user = User.new(id: nil, email: nil, role: :cohere)
      kase = cases(:opened_1)
      policy = Case::Policy.new(user, kase)
      assert(policy.forbid?(:view))
    end

    test "forbids dhs partners from viewing a case" do
      user = User.new(id: nil, email: nil, role: :dhs)
      kase = cases(:opened_1)
      policy = Case::Policy.new(user, kase, scope: :dhs)
      assert(policy.forbid?(:view))
    end

    test "forbids suppliers from viewing a case" do
      user = User.new(id: nil, email: nil, role: :supplier)
      kase = cases(:opened_1)
      policy = Case::Policy.new(user, kase, scope: :supplier)
      assert(policy.forbid?(:view))
    end

    # -- edit --
    test "permits operators to edit a case" do
      user = User.new(id: nil, email: nil, role: :cohere)
      kase = cases(:opened_1)
      policy = Case::Policy.new(user, kase)
      assert(policy.permit?(:edit))
    end

    test "permits dhs partners to edit a case" do
      user = User.new(id: nil, email: nil, role: :dhs)
      kase = cases(:opened_1)
      policy = Case::Policy.new(user, kase, scope: :dhs)
      assert(policy.permit?(:edit))
    end

    test "forbids enrollers from editing a case" do
      user = User.new(id: nil, email: nil, role: :enroller)
      kase = cases(:submitted_1)
      policy = Case::Policy.new(user, kase, scope: :enroller)
      assert(policy.forbid?(:edit))
    end

    test "forbids suppliers from editing a case" do
      user = User.new(id: nil, email: nil, role: :supplier)
      kase = cases(:opened_1)
      policy = Case::Policy.new(user, kase, scope: :supplier)
      assert(policy.forbid?(:edit))
    end

    # -- create --
    test "permits suppliers to create cases" do
      user = User.new(id: nil, email: nil, role: :supplier)
      policy = Case::Policy.new(user, scope: :supplier)
      assert(policy.permit?(:create))
    end

    test "forbids others from creating cases" do
      user = User.new(id: nil, email: nil, role: :operator)
      policy = Case::Policy.new(user)
      assert(policy.forbid?(:create))
    end

    # -- view properties --
    test "permits operators to view the case status" do
      user = User.new(id: nil, email: nil, role: :cohere)
      kase = cases(:opened_1)
      policy = Case::Policy.new(user, kase)
      assert(policy.permit?(:view_status))
    end

    test "forbids others from viewing the case status" do
      user = User.new(id: nil, email: nil, role: :enroller)
      kase = cases(:submitted_1)
      policy = Case::Policy.new(user, kase, scope: :enroller)
      assert(policy.forbid?(:view_status))
    end
  end
end
