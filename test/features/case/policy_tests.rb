class Case
  class PolicyTests < ActiveSupport::TestCase
    test "permits operators to list cases" do
      user = User::new(role: :cohere)
      policy = Case::Policy.new(user)
      assert(policy.permit?(:list))
    end

    test "permits enrollers to list cases" do
      user = User::new(role: :enroller)
      policy = Case::Policy.new(user)
      assert(policy.permit?(:list))
    end

    test "permits operators to show a case" do
      user = User::new(role: :cohere)
      kase = cases(:incomplete_1)
      policy = Case::Policy.new(user, kase)
      assert(policy.permit?(:show))
    end

    test "permits enrollers to show a case" do
      user = User::new(role: :enroller)
      kase = cases(:incomplete_2)
      policy = Case::Policy.new(user, kase)
      assert(policy.permit?(:show))
    end

    test "permits operators to view the case status" do
      user = User::new(role: :cohere)
      kase = cases(:incomplete_1)
      policy = Case::Policy.new(user, kase)
      assert(policy.permit?(:view_status))
    end

    test "forbids enrollers from viewing the case status" do
      user = User::new(role: :enroller)
      kase = cases(:incomplete_2)
      policy = Case::Policy.new(user, kase)
      assert(policy.forbid?(:view_status))
    end
  end
end
