module Cases
  module Views
    # A Case read model for rendering a cell in a list of cases.
    class Cell < ::Value
      include Case::Policy::Context::Shared
      include Routing
      include ActionView::Helpers::DateHelper

      # -- props --
      prop(:scope)
      prop(:id, default: Id::None)
      prop(:status)
      prop(:condition)
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
      delegate(:approved?, to: :status)
      delegate(:archived?, to: :condition)

      def status_name
        return @status.to_s.capitalize
      end

      def program_name
        return @program.name
      end

      def details_names
        names = [program_name, @supplier_name]

        if permit?(:view_details_enroller)
          names.push(@enroller_name)
        end

        return names.compact.join(", ")
      end

      # -- queries/assignment
      def shows_assign?
        return @scope.queued? && @assignee_email == nil
      end

      def assignee_email
        return @assignee_email&.split("@")&.first
      end

      # -- Case::Policy::Context --
      def case
        return self
      end
    end
  end
end
