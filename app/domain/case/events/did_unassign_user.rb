class Case
  module Events
    class DidUnassignUser < ::Value
      # -- props --
      prop(:case_id)
      prop(:assignment_role)
      prop(:assignment_partner_id)

      # -- factories --
      def self.from_entity(kase)
        a = kase.selected_assignment
        DidUnassignUser.new(
          case_id: kase.id,
          assignment_role: a.role,
          assignment_partner_id: a.partner_id,
        )
      end
    end
  end
end
