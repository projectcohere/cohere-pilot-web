module Routes
  module Fallback
    def fallback(name, to:, constraints:)
      path = to

      # root
      root(to: redirect(path), as: :"#{name}_root")

      # catchall
      get("*path",
        to: redirect(path),
        constraints: merge(constraints, ActiveStorageExceptionConstraint.new),
      )
    end

    class ActiveStorageExceptionConstraint
      def matches?(req)
        return req.path.exclude?("rails/active_storage")
      end
    end
  end
end
