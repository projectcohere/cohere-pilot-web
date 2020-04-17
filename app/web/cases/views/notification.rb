module Cases
  module Views
    # A Case read model for rendering a notification.
    class Notification < ::Value
      # -- props --
      prop(:id)
      prop(:status)
      prop(:recipient_name)
      prop(:enroller_id)

      # -- queries --
      def status_name
        return @status.to_s
      end
    end
  end
end
