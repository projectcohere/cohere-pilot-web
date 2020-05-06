module Routes
  module Constraints
    # constrain grouping
    def merge(*constraints)
      return ConstraintSet.new(constraints)
    end

    class ConstraintSet
      def initialize(constraints)
        @constraints = constraints
      end

      def matches?(req)
        return @constraints.all? { |c| c.matches?(req) }
      end
    end

    # query params
    def query(patterns)
      return QueryContraint.new(patterns)
    end

    class QueryContraint
      def initialize(**patterns)
        @patterns = patterns
      end

      def matches?(req)
        return @patterns.all? do |key, pattern|
          param = req.params[key] || ""
          param.match?(pattern)
        end
      end
    end

    # content type
    def content_type(content_type)
      return ContentTypeConstraint.new(content_type)
    end

    class ContentTypeConstraint
      def initialize(content_type)
        @content_type = content_type
      end

      def matches?(req)
        req.content_type == @content_type
      end
    end
  end
end
