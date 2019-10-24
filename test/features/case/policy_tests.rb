class Case
  # TODO: randomize scope/role pairs for catch-all forbid tests
  class PolicyTests < ActiveSupport::TestCase
    # -- scopes --
    test "restricts operators to unscoped cases" do
      user = User::new(id: nil, role: :cohere)

      policy = Case::Policy.new(user)
      assert(policy.permit?(:some))

      policy = Case::Policy.new(user, scope: :opened)
      assert(policy.forbid?(:any))
    end

    test "restricts enrollers to unscoped cases" do
      user = User::new(id: nil, role: :enroller)

      policy = Case::Policy.new(user)
      assert(policy.permit?(:some))

      policy = Case::Policy.new(user, scope: :opened)
      assert(policy.forbid?(:any))
    end

    test "restricts suppliers to inbound cases" do
      user = User::new(id: nil, role: :supplier)

      policy = Case::Policy.new(user, scope: :inbound)
      assert(policy.permit?(:some))

      policy = Case::Policy.new(user)
      assert(policy.forbid?(:any))
    end

    test "restricts dhs partners to opened cases" do
      user = User::new(id: nil, role: :dhs)

      policy = Case::Policy.new(user, scope: :opened)
      assert(policy.permit?(:some))

      policy = Case::Policy.new(user)
      assert(policy.forbid?(:any))
    end

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

    test "permits dhs partners to list opened cases" do
      user = User::new(id: nil, role: :dhs)
      policy = Case::Policy.new(user, scope: :opened)
      assert(policy.permit?(:list))
    end

    test "permits suppliers to list inbound cases" do
      user = User::new(id: nil, role: :supplier)
      policy = Case::Policy.new(user, scope: :inbound)
      assert(policy.permit?(:list))
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
      kase = cases(:submitted_1)
      policy = Case::Policy.new(user, kase)
      assert(policy.permit?(:edit))
    end

    test "permits dhs partners to edit a case" do
      user = User::new(id: nil, role: :dhs)
      kase = cases(:opened_1)
      policy = Case::Policy.new(user, kase, scope: :opened)
      assert(policy.permit?(:edit))
    end

    test "forbids others from editing a case" do
      user = User::new(id: nil, role: :supplier)
      kase = cases(:submitted_1)
      policy = Case::Policy.new(user, kase, scope: :inbound)
      assert(policy.forbid?(:edit))
    end

    # -- create --
    test "permits suppliers to create cases" do
      user = User::new(id: nil, role: :supplier)
      policy = Case::Policy.new(user, scope: :inbound)
      assert(policy.permit?(:create))
    end

    test "forbids others from creating cases" do
      user = User::new(id: nil, role: :operator)
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

    test "forbids others from viewing the case status" do
      user = User::new(id: nil, role: :enroller)
      kase = cases(:submitted_1)
      policy = Case::Policy.new(user, kase)
      assert(policy.forbid?(:view_status))
    end
  end
end
