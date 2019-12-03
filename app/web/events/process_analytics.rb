module Events
  class ProcessAnalytics
    # -- constants --
    Unsaved = "Unsaved".freeze

    # -- lifetime --
    def self.get
      ProcessAnalytics.new
    end

    def initialize(
      user_repo: User::Repo.get,
      analytics_events: Services.analytics_events
    )
      @user_repo = user_repo
      @analytics_events = analytics_events
    end

    # -- commands --
    def call(event)
      # add event attrs
      id = case event
      when Cases::Events::DidViewSupplierForm
        Unsaved
      when Case::Events::DidOpen
        event.case_id.val
      when Cases::Events::DidViewDhsForm
        event.case_id.val
      when Case::Events::DidBecomePending
        event.case_id.val
      when Case::Events::DidReceiveMessage
        event.case_id.val
      when Case::Events::DidSubmit
        event.case_id.val
      when Cases::Events::DidViewEnrollerCase
        event.case_id.val
      when Case::Events::DidComplete
        event.case_id.val
      end

      # bail if we don't log this event
      if id.nil?
        return
      end

      # determine event name
      event_path = event.class.name.split("::")
      event_name = event_path[2].titlecase

      # determine event attrs
      event_attrs = case event
      when Case::Events::DidReceiveMessage
        { is_first: event.is_first }
      when Case::Events::DidComplete
        { case_status: event.case_status }
      else
        { }
      end

      # add user attrs if available
      @user_repo.find_current&.tap do |u|
        event_attrs.merge!(
          user_id: u.id.val
        )
      end

      # track event
      tracker.track(id, event_name, event_attrs)
    end

    # -- helpers --
    private def tracker
      @tracker ||= begin
        Mixpanel::Tracker.new(ENV["MIXPANEL_TOKEN"]) do |type, message|
          @analytics_events << [type, message].to_json
        end
      end
    end
  end
end