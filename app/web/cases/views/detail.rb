module Cases
  module Views
    # This is a read model representing one case in a list of cases.
    class Detail < ::Value
      include ActionView::Helpers::DateHelper
      include ActionView::Helpers::NumberHelper

      # -- props --
      prop(:id)
      prop(:status)
      prop(:program)
      prop(:enroller_name)
      prop(:supplier_name)
      prop(:supplier_account)
      prop(:recipient_profile)
      prop(:recipient_household)
      prop(:referrer, predicate: true)
      prop(:referred, predicate: true)
      prop(:documents)

      # -- props/remove
      # TODO: remove this once the chat view is integrated into the detail
      prop(:recipient_id)

      # -- queries --
      def status
        return @status.to_s.capitalize
      end

      def recipient_name
        return @recipient_profile.name
      end

      def program_name
        return @program.to_s.upcase
      end

      # -- queries/contact
      def address
        return @recipient_profile.address.lines
      end

      def phone_number
        return "+1 #{number_to_phone(@recipient_profile.phone.number)}"
      end

      # -- queries/account
      def supplier_account_number
        return @supplier_account.number
      end

      def supplier_account_arrears
        return "$#{@supplier_account.arrears.dollars}"
      end

      def supplier_account_active_service?
        return @supplier_account.active_service?
      end

      # -- queries/household
      def household_dhs_number
        return @household&.dhs_number || "Unknown"
      end

      def household_size
        return @household&.size || "Unknown"
      end

      def household_income
        return @household&.income&.dollars&.then { |f| "$#{f}" } || "Unknown"
      end

      def household_ownership
        return @household&.ownership&.to_s&.titlecase
      end

      def household_primary_residence?
        return @household&.primary_residence?
      end

      def household_fpl_percent
        return @household&.fpl_percent&.then { |f| "#{f}%" }
      end

      # -- queries/complete
      def can_complete?
        return Case::Status.submitted?(@status)
      end

      def approve_path
        return urls.case_completePath(@id, complete_action: :approve)
      end

      def deny_path
        return urls.case_completePath(@id, complete_action: :deny)
      end

      # -- queries/referral
      def can_make_referral?
        return Case::Status.complete?(@status) && !@referral && !@referrer
      end

      def referral_label
        return "Make Referral to #{referral_program.to_s.upcase}"
      end

      def referral_path
        return urls.new_case_referral_path(@id)
      end

      def referral_program
        return @program.referral_program
      end

      # -- queries/helpers
      private def urls
        return Rails.application.routes.url_helpers
      end
    end
  end
end
