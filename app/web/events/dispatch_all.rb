module Events
  class DispatchAll
    # -- lifetime --
    def self.get
      Events::DispatchAll.new
    end

    def initialize(
      domain_events: Services.domain_events,
      dispatch_analytics: DispatchAnalytics.get
    )
      @domain_events = domain_events
      @dispatch_analytics = dispatch_analytics
    end

    # -- command --
    def call
      @domain_events.drain do |event|
        dispatch(event)
        @dispatch_analytics.(event)
      end
    end

    private def dispatch(event)
      case event
      when Case::Events::DidOpen
        if not event.case_is_referred
          deliver(CasesMailer.did_open(
            event.case_id.val,
          ))

          Chats::OpenChat.(
            event.case_recipient_id.val,
          )
        end

        Cohere::PublishQueuedCase.perform_async(
          event.case_id.val,
        )

        Dhs::PublishQueuedCase.perform_async(
          event.case_id.val,
        )
      when Case::Events::DidSubmit
        deliver(CasesMailer.did_submit(
          event.case_id.val,
        ))

        Enroller::PublishQueuedCase.perform_async(
          event.case_id.val,
        )
      when Case::Events::DidComplete
        if event.case_status != Case::Status::Removed
          deliver(CasesMailer.did_complete(
            event.case_id.val,
          ))
        end
      when Case::Events::DidUploadMessageAttachment
        Cases::AttachFrontFileWorker.perform_async(
          event.case_id.val,
          event.document_id.val,
        )
      when Case::Events::DidSignContract
        Cases::AttachContractWorker.perform_async(
          event.case_id.val,
          event.document_id.val,
        )
      when Case::Events::DidChangeActivity
        Cohere::PublishActivity.perform_async(
          event.case_id.val,
          event.case_has_new_activity,
        )
      when User::Events::DidInvite
        deliver(UsersMailer.did_invite(
          event.user_id.val,
        ))
      when Chat::Events::DidAddMessage
        Chats::PublishMessage.perform_async(
          event.chat_message_id.val,
        )

        Cases::AddChatMessage.(
          event.chat_message_id.val,
        )
      end
    end

    # -- command/helpers
    private def deliver(mail)
      mail.deliver_later
    end
  end
end
