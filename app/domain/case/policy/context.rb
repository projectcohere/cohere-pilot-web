class Case
  class Policy
    # Context module for mixing in cross-cutting authorization concerns.
    # Provides accessors and helpers for the current policy.
    module Context
      extend ActiveSupport::Concern

      # -- includes --
      include ::Policy::Context

      # -- queries --
      # constructs a case policy
      def policy
        return Case::Policy.new(user, self.case)
      end

      # returns the case used to construct the policy. defaults to `@case`.
      def case
        return @case
      end

      # -- children --
      # Includes all of the above, but the policy is memoized. Use this
      # when the value of `case` does not change.
      module Shared
        extend ActiveSupport::Concern

        # -- includes --
        include Context

        # -- queries --
        def policy
          return @policy ||= super
        end
      end
    end
  end
end
