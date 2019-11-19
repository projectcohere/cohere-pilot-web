module Events
  class Analytics
    # -- lifetime --
    def self.get
      Analytics.new
    end

    def initialize(user_repo: User::Repo.get)
      @user_repo = user_repo
    end

    # -- commands --
    def process_event(event)
      # add event attrs
      attrs = case event
      when Cases::Events::DidViewSupplierForm
        { }
      when Case::Events::DidOpen
        { case_id: event.case_id }
      when Cases::Events::DidViewDhsForm
        { case_id: event.case_id }
      when Case::Events::DidBecomePending
        { case_id: event.case_id }
      when Case::Events::DidSubmit
        { case_id: event.case_id }
      when Case::Events::DidComplete
        { case_id: event.case_id, case_status: event.case_status }
      end

      # bail if we don't log this event
      if attrs.nil?
        return
      end

      # add user attrs if available
      @user_repo.find_current&.tap do |u|
        attrs.merge!({
          user_email: u.email,
          user_role: u.role.name
        })
      end

      # add event attrs
      event_path = event.class.name.split("::")
      attrs.merge!({
        event_scope: event_path[0].pluralize,
        event_name: event_path[2]
      })

      # format log message
      logger.info("[Analytics] #{attrs.to_json}")
    end

    # -- helpers --
    private def logger
      Rails.logger
    end
  end
end
