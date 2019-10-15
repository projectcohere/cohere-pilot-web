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

    # -- show --
    test "permits operators to see a case" do
      user = User::new(id: nil, role: :cohere)
      kase = cases(:incomplete_1)
      policy = Case::Policy.new(user, kase)
      assert(policy.permit?(:show))
    end

    test "permits enrollers to see a case" do
      user = User::new(id: nil, role: :enroller)
      kase = cases(:incomplete_2)
      policy = Case::Policy.new(user, kase)
      assert(policy.permit?(:show))
    end

    test "forbids suppliers from seeing a case" do
      user = User::new(id: nil, role: :supplier)
      kase = cases(:incomplete_2)
      policy = Case::Policy.new(user, kase)
      assert(policy.forbid?(:show))
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
      kase = cases(:incomplete_1)
      policy = Case::Policy.new(user, kase)
      assert(policy.permit?(:view_status))
    end

    test "forbids enrollers from viewing the case status" do
      user = User::new(id: nil, role: :enroller)
      kase = cases(:incomplete_2)
      policy = Case::Policy.new(user, kase)
      assert(policy.forbid?(:view_status))
    end

    test "forbids suppliers from viewing the case status" do
      user = User::new(id: nil, role: :supplier)
      kase = cases(:incomplete_2)
      policy = Case::Policy.new(user, kase)
      assert(policy.forbid?(:view_status))
    end
  end
end
