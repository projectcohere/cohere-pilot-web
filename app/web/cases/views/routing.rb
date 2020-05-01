module Cases
  module Views
    module Routing
      def list_path
        return urls.cases_path
      end

      def new_path
        return urls.new_case_path
      end

      def detail_path(status = nil)
        return (status || @status).complete? ? show_path : edit_path
      end

      def show_path
        return urls.case_path(@id)
      end

      def edit_path
        return urls.edit_case_path(@id)
      end

      def update_path
        return urls.case_path(@id)
      end

      def delete_path
        return urls.case_path(@id)
      end

      def assign_path
        return urls.case_assignments_path(@id)
      end

      def remove_path
        return urls.case_path(@id)
      end

      def approve_path
        return urls.case_complete_path(@id, complete_action: :approve)
      end

      def deny_path
        return urls.case_complete_path(@id, complete_action: :deny)
      end

      def select_referral_path
        return urls.select_case_referrals_path(@id)
      end

      def start_referral_path
        return urls.new_case_referral_path(@id)
      end

      def urls
        return Rails.application.routes.url_helpers
      end
    end
  end
end
