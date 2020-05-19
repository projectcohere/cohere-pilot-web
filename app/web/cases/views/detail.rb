module Cases
  module Views
    # A Case read model for rendering a detail view.
    class Detail < ::Value
      include Routing
      include ActionView::Helpers::DateHelper
      include ActionView::Helpers::NumberHelper

      # -- props --
      prop(:id, default: Id::None)
      prop(:status)
      prop(:condition)
      prop(:program)
      prop(:enroller_name)
      prop(:supplier_name)
      prop(:supplier_account)
      prop(:recipient_id)
      prop(:profile)
      prop(:household)
      prop(:benefit)
      prop(:documents)
      prop(:assignments)
      prop(:notes)

      # -- lifetime --
      def initialize(chat_repo: Chat::Repo.get, **props)
        @chat_repo = chat_repo
        super(props)
      end

      # -- queries --
      def id_text
        return "##{@id}"
      end

      def status_name
        return @status.to_s.capitalize
      end

      def recipient_name
        return @profile.name
      end

      def recipient_first_name
        return recipient_name.first
      end

      def program_name
        return @program.name
      end

      # -- queries/contact
      def address
        return @profile.address.lines
      end

      def phone_number
        return "+1 #{number_to_phone(@profile.phone.number)}"
      end

      # -- queries/account
      def supplier_account_number
        return @supplier_account.number
      end

      def supplier_account_arrears
        return format_money(@supplier_account&.arrears)
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

      def household_proof_of_income
        return @household&.proof_of_income
      end

      def household_income
        return format_money(@household&.income)
      end

      def household_ownership
        return @household&.ownership&.to_s&.titlecase
      end

      def household_fpl_percent
        return @household&.fpl_percent&.then { |f| "#{f}%" }
      end

      # -- queries/benefit
      def benefit_amount
        return format_money(@benefit)
      end

      # -- queries/documents
      def contract
        return @documents.find { |d| d.classification == :contract }
      end

      # -- queries/actions
      def can_submit?
        return @status.opened? || @status.returned?
      end

      alias :can_remove? :can_submit?

      def can_convert?
        return @status.returned?
      end

      def can_complete?
        return @status.submitted?
      end

      def can_archive?
        return @condition.active? && @status.complete?
      end

      delegate(:archived?, to: :condition)

      # -- queries/referral
      def can_make_referral?
        return @status.approved?
      end

      # -- queries/chat
      def chat
        # TODO: return Chats::Views::Detail instead of entity
        return @chat ||= @chat_repo.find_by_recipient_with_messages(recipient_id)
      end

      # -- queries/helpers
      private def format_money(money)
        return money != nil ? "$#{money.dollars}" : "Unknown"
      end
    end
  end
end
