module Events
  class DispatchAnalytics < ::Command
    include User::Context

    # -- constants --
    Unsaved = "Unsaved".freeze

    # -- lifetime --
    def initialize(analytics: ListQueue.new)
      @analytics = analytics
    end

    # -- commands --
    def call(event)
      # add event attrs
      id = case event
      when Cases::Events::DidViewSourceForm
        Unsaved
      when Case::Events::DidOpen
        event.case_id.val
      when Cases::Events::DidViewGovernorForm
        event.case_id.val
      when Cases::Events::DidSaveGovernorForm
        event.case_id.val
      when Case::Events::DidReceiveMessage
        event.case_id.val
      when Case::Events::DidSubmitToEnroller
        event.case_id.val
      when Cases::Events::DidViewEnrollerCase
        event.case_id.val
      when Case::Events::DidReturnToAgent
        event.case_id.val
      when Case::Events::DidComplete
        event.case_id.val
      when Case::Events::DidMakeReferral
        event.case_id.val
      end

      # bail if we don't log this event
      if id == nil
        return
      end

      # determine event name
      data = { name: event.class.name.demodulize }

      # determine event attrs
      if event.respond_to?(:temp_id) && event.temp_id&.val != nil
        data[:temp_id] = event.temp_id.val
      end

      if event.respond_to?(:case_program)
        data[:case_program] = event.case_program.id
      end

      if event.respond_to?(:case_is_referred)
        data[:case_is_referred] = event.case_is_referred
      end

      case event
      when Case::Events::DidReceiveMessage
        data[:is_first] = event.is_first
      when Case::Events::DidComplete
        data[:case_status] = event.case_status
      end

      # add user attrs if available
      if user != nil
        data[:user_id] = user.id.val
      end

      # add event
      @analytics.add(data)
    end

    def drain
      return @analytics.drain
    end
  end
end
