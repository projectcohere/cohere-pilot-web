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
        dispatch(event)
        @process_analytics.(event)
      end
    end

    private def dispatch(event)
      case event
      when Case::Events::DidOpen
        if not event.case_is_referred
          deliver(CasesMailer.did_open(
            event.case_id.val
          ))

          Chats::OpenChat.(
            event.case_recipient_id.val
          )

          Chats::SendInvite.(
            event.case_recipient_phone_number
          )
        end
      when Case::Events::DidSubmit
        deliver(CasesMailer.did_submit(
          event.case_id.val
        ))
      when Case::Events::DidComplete
        if event.case_status != Case::Status::Removed
          deliver(CasesMailer.did_complete(
            event.case_id.val
          ))
        end
      when Case::Events::DidUploadMessageAttachment
        Cases::AttachFrontFileWorker.perform_async(
          event.case_id.val,
          event.document_id.val
        )
      when Case::Events::DidSignContract
        Cases::AttachContractWorker.perform_async(
          event.case_id.val,
          event.document_id.val
        )
      when Case::Events::DidChangeActivity
        Cases::PublishActivity.perform_async(
          event.case_id.val,
          event.case_has_new_activity,
        )
      when User::Events::DidInvite
        deliver(UsersMailer.did_invite(
          event.user_id.val
        ))
      when Chat::Events::DidAddMessage
        Chats::PublishMessage.perform_async(
          event.chat_message_id.val
        )

        Cases::AddChatMessage.perform_async(
          event.chat_message_id.val
        )
      end
    end

    # -- command/helpers
    private def deliver(mail)
      mail.deliver_later
    end
  end
end
