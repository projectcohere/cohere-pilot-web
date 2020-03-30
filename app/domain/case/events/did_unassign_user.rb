class Case
  module Events
    class DidUnassignUser < ::Value
      # -- props --
      prop(:case_id)
      prop(:partner_id)

      # -- factories --
      def self.from_entity(kase)
        assignment = kase.selected_assignment

        DidUnassignUser.new(
          case_id: kase.id,
          partner_id: assignment.partner_id,
        )
      end
    end
  end
end
