class Case
  module Events
    class DidChangeActivity < ::Value
      # -- props --
      prop(:case_id)
      prop(:case_new_activity, predicate: true)

      # -- equality --
      def ==(other)
        return other.is_a?(DidChangeActivity) && @case_id == other.case_id
      end

      # -- factories --
      def self.from_entity(kase)
        DidChangeActivity.new(
          case_id: kase.id,
          case_new_activity: kase.new_activity?,
        )
      end
    end
  end
end
