module Events
  class DispatchAll < ::Command
    include Service::Singleton

    # -- lifetime --
    def initialize(
      domain_events: Service::Container.domain_events,
      dispatch_analytics: DispatchAnalytics.get
    )
      @domain_events = domain_events
      @dispatch_analytics = dispatch_analytics
    end

    # -- command --
    def call
      # if events are already being drained, we don't want to do accidentally execute
      # duplicate work (this really only happens in tests when workers run inline)
      if @draining
        return
      end

      @draining = true
      @domain_events.drain do |event|
        dispatch(event)
        @dispatch_analytics.(event)
      end
      @draining = false
    end

    private def dispatch(event)
      case event
      when User::Events::DidInvite
        deliver(Users::Mailer.did_invite(
          event.user_id.val,
        ))
      when Case::Events::DidOpen
        if not event.case_is_referred
          Chats::OpenChat.(
            event.case_recipient_id.val,
          )

          deliver(Cases::Mailer.did_open(
            event.case_id.val,
          ))
        end

        Cohere::PublishQueuedCase.perform_async(
          event.case_id.val,
        )

        Dhs::PublishQueuedCase.perform_async(
          event.case_id.val,
        )
      when Case::Events::DidAssignUser
        if event.partner_membership != Partner::Membership::Supplier
          Cases::PublishAssignUser.perform_async(
            event.case_id.val,
            event.partner_id,
          )
        end
      when Case::Events::DidUnassignUser
        if event.partner_membership != Partner::Membership::Supplier
          Cases::PublishUnassignUser.perform_async(
            event.case_id.val,
            event.partner_id,
          )
        end
      when Case::Events::DidSubmit
        deliver(Cases::Mailer.did_submit(
          event.case_id.val,
        ))

        Enroller::PublishQueuedCase.perform_async(
          event.case_id.val,
        )
      when Case::Events::DidComplete
        if event.case_status != Case::Status::Removed
          deliver(Cases::Mailer.did_complete(
            event.case_id.val,
          ))
        end
      when Case::Events::DidSignContract
        Cases::AttachContract.perform_async(
          event.case_id.val,
          event.document_id.val,
        )
      when Case::Events::DidChangeActivity
        Cohere::PublishActivity.perform_async(
          event.case_id.val,
          event.case_has_new_activity,
        )
      when Chat::Events::DidAddRemoteAttachment
        Chats::UploadRemoteAttachment.perform_async(
          event.attachment_id.val,
        )
      when Chat::Events::DidUploadAttachment
        Chats::PrepareMessage.perform_async(
          event.message_id,
        )

        Chats::DeleteRemoteAttachment.perform_async(
          event.attachment_url,
        )
      when Chat::Events::DidPrepareMessage
        Chats::SendWebMessage.perform_async(
          event.message_id.val,
        )

        if not Chat::Sender.recipient?(event.message_sender)
          Chats::SendSmsMessage.perform_async(
            event.message_id.val,
          )
        end

        Cases::AddChatMessage.perform_async(
          event.message_id.val,
        )
      end
    end

    # -- command/helpers
    private def deliver(mail)
      mail.deliver_later
    end
  end
end
