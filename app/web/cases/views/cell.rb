module Cases
  module Views
    # A Case read model for rendering a cell in a list of cases.
    class Cell < ::Value
      include Routing
      include ActionView::Helpers::DateHelper

      # -- props --
      prop(:scope)
      prop(:id, default: Id::None)
      prop(:status)
      prop(:new_activity, predicate: true)
      prop(:program)
      prop(:recipient_name)
      prop(:supplier_name)
      prop(:enroller_name)
      prop(:assignee_email)
      prop(:created_at)
      prop(:updated_at)

      # -- queries --
      # -- queries/labels
      def assign_label
        return "Assign to Me"
      end

      def created_label
        return "Opened #{@created_at.to_date}"
      end

      def updated_label
        return "Updated #{time_ago_in_words(@updated_at)} ago"
      end

      # -- queries/details
      def status_name
        return @status.to_s.capitalize
      end

      def program_name
        return @program.name
      end

      def details_names
        return [program_name, @supplier_name, @enroller_name].compact
      end

      def approved?
        return @status == Case::Status::Approved
      end

      # -- queries/assignment
      def shows_assign?
        return @scope.queued? && @assignee_email == nil
      end

      def assignee_email
        return @assignee_email&.split("@")&.first
      end
    end
  end
end
