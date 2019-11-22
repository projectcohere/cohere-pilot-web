module Events
  class ProcessAnalytics
    # -- lifetime --
    def self.get
      ProcessAnalytics.new
    end

    def initialize(
      user_repo: User::Repo.get,
      tracking_events: Services.tracking_events
    )
      @user_repo = user_repo
      @tracking_events = tracking_events
    end

    # -- commands --
    def call(event)
      # add event attrs
      id = case event
      when Case::Events::DidOpen
        event.case_id
      when Cases::Events::DidViewDhsForm
        event.case_id
      when Case::Events::DidBecomePending
        event.case_id
      when Case::Events::DidReceiveFirstMessage
        event.case_id
      when Case::Events::DidSubmit
        event.case_id
      when Case::Events::DidComplete
        event.case_id
      end

      # bail if we don't log this event
      if id.nil?
        return
      end

      # determine event name
      event_path = event.class.name.split("::")
      event_name = event_path[2]

      # determine event attrs
      event_attrs = case event
      when Case::Events::DidComplete
        { case_status: event.case_status }
      else
        { }
      end

      # track event
      tracker.track(id, event_name, event_attrs)
    end

    # -- helpers --
    private def tracker
      @tracker ||= begin
        Mixpanel::Tracker.new(ENV["MIXPANEL_TOKEN"]) do |type, message|
          @tracking_events << [type, message].to_json
        end
      end
    end
  end
end
