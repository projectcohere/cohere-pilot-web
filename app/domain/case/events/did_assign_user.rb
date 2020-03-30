class Case
  module Events
    class DidAssignUser < ::Value
      # -- props --
      prop(:case_id)
      prop(:user_id)
      prop(:partner_id)

      # -- factories --
      def self.from_entity(kase)
        assignment = kase.new_assignment

        DidAssignUser.new(
          case_id: kase.id,
          user_id: assignment.user_id,
          partner_id: assignment.partner_id,
        )
      end
    end
  end
end
