module Cases
  module Views
    # A Case read model for rendering a contract.
    class Contract < ::Value
      include ActionView::Helpers::NumberHelper

      # -- props --
      prop(:date)
      prop(:profile)

      # -- queries --
      def recipient_name
        return @profile.name
      end

      def phone_number
        return "+1 #{number_to_phone(@profile.phone.number)}"
      end

      def address
        return @profile.address.lines
      end
    end
  end
end
