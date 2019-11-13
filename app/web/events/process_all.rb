module Events
  class ProcessAll
    # -- lifetime --
    def self.get
      Events::ProcessAll.new
    end

    def initialize(event_queue: EventQueue.get)
      @event_queue = event_queue
    end

    # -- command --
    def call
      @event_queue.drain do |event|
        case event
        when Case::Events::DidOpen
          CasesMailer.did_open(event.case_id.val).deliver_later
        when Case::Events::DidSubmit
          CasesMailer.did_submit(event.case_id.val).deliver_later
        when Case::Events::DidUploadMessageAttachment
          Cases::AttachFrontFileWorker.perform_async(event.case_id.val, event.document_id.val)
        when Case::Events::DidSignContract
          Cases::AttachContractWorker.perform_async(event.case_id.val, event.document_id.val)
        when User::Events::DidInvite
          UsersMailer.did_invite(event.user_id.val).deliver_later
        end
      end
    end
  end
end