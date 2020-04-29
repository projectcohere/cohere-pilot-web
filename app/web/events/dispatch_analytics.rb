module Events
  class DispatchAnalytics < ::Command
    include User::Context

    # -- constants --
    Unsaved = "Unsaved".freeze

    # -- lifetime --
    def initialize(analytics_events: Service::Container.analytics_events)
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
      when Cases::Events::DidViewGovernorForm
        event.case_id.val
      when Case::Events::DidBecomePending
        event.case_id.val
      when Case::Events::DidReceiveMessage
        event.case_id.val
      when Case::Events::DidSubmit
        event.case_id.val
      when Cases::Events::DidViewEnrollerCase
        event.case_id
      when Case::Events::DidComplete
        event.case_id.val
      when Case::Events::DidMakeReferral
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
      event_attrs = {}
      if event.respond_to?(:case_program)
        event_attrs[:case_program] = event.case_program
      end

      if event.respond_to?(:case_is_referred)
        event_attrs[:case_is_referred] = event.case_is_referred
      end

      other_attrs = case event
      when Case::Events::DidReceiveMessage
        { is_first: event.is_first }
      when Case::Events::DidComplete
        { case_status: event.case_status }
      end

      if not other_attrs.nil?
        event_attrs.merge!(other_attrs)
      end

      # add user attrs if available
      user&.tap do |u|
        event_attrs.merge!(user_id: u.id.val)
      end

      # track event
      tracker.track(id, event_name, event_attrs)
    end

    # -- helpers --
    private def tracker
      @tracker ||= begin
        Mixpanel::Tracker.new(ENV["MIXPANEL_TOKEN"]) do |type, message|
          @analytics_events.add([type, message].to_json)
        end
      end
    end
  end
end
