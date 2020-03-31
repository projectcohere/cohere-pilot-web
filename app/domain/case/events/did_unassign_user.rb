class Case
  module Events
    class DidUnassignUser < ::Value
      # -- props --
      prop(:case_id)
      prop(:partner_id)
      prop(:partner_membership)

      # -- factories --
      def self.from_entity(kase)
        assignment = kase.selected_assignment

        DidUnassignUser.new(
          case_id: kase.id,
          partner_id: assignment.partner_id,
          partner_membership: assignment.partner_membership,
        )
      end
    end
  end
end
