module Cases
  module Views
    # A Case read model for rendering a contract.
    class Contract < ::Value
      include ActionView::Helpers::NumberHelper

      # -- props --
      prop(:date)
      prop(:recipient_profile)

      # -- queries --
      def recipient_name
        return @recipient_profile.name
      end

      def phone_number
        return "+1 #{number_to_phone(@recipient_profile.phone.number)}"
      end

      def address
        return @recipient_profile.address.lines
      end
    end
  end
end
