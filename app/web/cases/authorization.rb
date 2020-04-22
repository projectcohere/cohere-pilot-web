module Cases
  module Authorization
    extend ActiveSupport::Concern

    # -- includes --
    include ::Authorization

    # -- commands --
    def permit!(key)
      if policy.forbid?(key)
        deny_access
      end
    end

    # -- queries --
    def policy
      return Case::Policy.new(user, @case)
    end
  end
end
