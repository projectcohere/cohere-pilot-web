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
  end
end
