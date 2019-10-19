class Case
  class PolicyTests < ActiveSupport::TestCase
    # -- list --
    test "permits operators to list cases" do
      user = User::new(id: nil, role: :cohere)
      policy = Case::Policy.new(user)
      assert(policy.permit?(:list))
    end

    test "permits enrollers to list cases" do
      user = User::new(id: nil, role: :enroller)
      policy = Case::Policy.new(user)
      assert(policy.permit?(:list))
    end

    test "forbids suppliers from listing cases" do
      user = User::new(id: nil, role: :supplier)
      policy = Case::Policy.new(user)
      assert(policy.forbid?(:list))
    end

    # -- edit --
    test "permits operators to edit a case" do
      user = User::new(id: nil, role: :cohere)
      kase = cases(:opened_1)
      policy = Case::Policy.new(user, kase)
      assert(policy.permit?(:edit))
    end

    test "permits enrollers to edit a case" do
      user = User::new(id: nil, role: :enroller)
      kase = cases(:pending_1)
      policy = Case::Policy.new(user, kase)
      assert(policy.permit?(:edit))
    end

    test "permits dhs partners to edit a case" do
      user = User::new(id: nil, role: :dhs)
      kase = cases(:opened_1)
      policy = Case::Policy.new(user, kase)
      assert(policy.permit?(:edit))
    end

    test "forbids suppliers from editing a case" do
      user = User::new(id: nil, role: :supplier)
      kase = cases(:pending_1)
      policy = Case::Policy.new(user, kase)
      assert(policy.forbid?(:edit))
    end

    # -- create --
    test "permits suppliers to create cases" do
      user = User::new(id: nil, role: :supplier)
      policy = Case::Policy.new(user)
      assert(policy.permit?(:create))
    end

    test "forbids operators from creating cases" do
      user = User::new(id: nil, role: :operator)
      policy = Case::Policy.new(user)
      assert(policy.forbid?(:create))
    end

    test "forbids enrollers from creating cases" do
      user = User::new(id: nil, role: :enroller)
      policy = Case::Policy.new(user)
      assert(policy.forbid?(:create))
    end

    # -- view properties --
    test "permits operators to view the case status" do
      user = User::new(id: nil, role: :cohere)
      kase = cases(:opened_1)
      policy = Case::Policy.new(user, kase)
      assert(policy.permit?(:view_status))
    end

    test "forbids enrollers from viewing the case status" do
      user = User::new(id: nil, role: :enroller)
      kase = cases(:pending_1)
      policy = Case::Policy.new(user, kase)
      assert(policy.forbid?(:view_status))
    end

    test "forbids suppliers from viewing the case status" do
      user = User::new(id: nil, role: :supplier)
      kase = cases(:pending_1)
      policy = Case::Policy.new(user, kase)
      assert(policy.forbid?(:view_status))
    end
  end
end
