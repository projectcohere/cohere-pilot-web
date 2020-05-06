class Case
  class Policy
    # context module for mixing in cross-cutting concerns.
    # provides accessors and helpers for the current case policy.
    module Context
      extend ActiveSupport::Concern

      # -- includes --
      include User::Context

      # -- queries --
      # constructs a case policy
      def policy
        return Case::Policy.new(user, self.case)
      end

      # returns the case used to construct the policy. defaults
      # to `@case`.
      def case
        return @case
      end

      # expose permit? and forbit? on the includer
      delegate(:permit?, :forbid?, to: :policy)

      # -- children --
      # includes all of the above, but the case policy is memoized.
      # use this when the value of `case` does not change.
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
