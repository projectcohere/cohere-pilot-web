module Events
  class ProcessAll
    # -- lifetime --
    def self.get
      Events::ProcessAll.new
    end

    def initialize(
      domain_events: Services.domain_events,
      process_analytics: ProcessAnalytics.get
    )
      @domain_events = domain_events
      @process_analytics = process_analytics
    end

    # -- command --
    def call
      @domain_events.drain do |event|
        case event
        when Case::Events::DidOpen
          CasesMailer.did_open(event.case_id.val).deliver_later
        when Case::Events::DidSubmit
          CasesMailer.did_submit(event.case_id.val).deliver_later
        when Case::Events::DidComplete
          CasesMailer.did_complete(event.case_id.val).deliver_later
        when Case::Events::DidUploadMessageAttachment
          Cases::AttachFrontFileWorker.perform_async(event.case_id.val, event.document_id.val)
        when Case::Events::DidSignContract
          Cases::AttachContractWorker.perform_async(event.case_id.val, event.document_id.val)
        when User::Events::DidInvite
          UsersMailer.did_invite(event.user_id.val).deliver_later
        end

        @process_analytics.(event)
      end
    end
  end
end
