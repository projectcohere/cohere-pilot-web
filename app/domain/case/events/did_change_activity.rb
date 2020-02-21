class Case
  module Events
    class DidChangeActivity < ::Value
      # -- props --
      prop(:case_id)
      prop(:case_has_new_activity)

      # -- factories --
      def self.from_entity(kase)
        DidChangeActivity.new(
          case_id: kase.id,
          case_has_new_activity: kase.has_new_activity,
        )
      end
    end
  end
end
