class Policy
  # Context module for mixing in cross-cutting authorization concerns.
  # Provides accessors and helpers for the current policy.
  module Context
    extend ActiveSupport::Concern

    # -- includes --
    include User::Context

    # -- queries --
    # constructs an base policy
    def policy
      return Policy.new(user)
    end

    # expose permit? and forbit? on the includer
    delegate(:permit?, :forbid?, to: :policy)

    # -- children --
    # Includes all of the above, but the policy is memoized. Use this
    # when the value of `user` does not change.
    # TODO: pick a strategy for re-using this module for all policy contexts.
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
