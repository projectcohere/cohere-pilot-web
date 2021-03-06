module Events
  class DispatchEffects < ::Command
    # -- command --
    def call(event)
      case event
      when User::Events::DidInvite
        deliver(Users::Mailer.did_invite(
          event.user_id.val,
        ), now: true)
      when Case::Events::DidOpen
        Chats::OpenChat.(
          event.case_recipient_id.val,
        )

        Agent::PublishQueuedCase.perform_async(
          event.case_id.val,
        )

        Governor::PublishQueuedCase.perform_async(
          event.case_id.val,
        )
      when Case::Events::DidAssignUser
        if not event.assignment_role.source?
          Cases::PublishAssignUser.perform_async(
            event.case_id.val,
            event.assignment_partner_id,
            event.assignment_role.key,
          )
        end
      when Case::Events::DidUnassignUser
        if not event.assignment_role.source?
          Cases::PublishUnassignUser.perform_async(
            event.case_id.val,
            event.assignment_partner_id,
            event.assignment_role.key,
          )
        end
      when Case::Events::DidSubmitToEnroller
        Enroller::PublishQueuedCase.perform_async(
          event.case_id.val,
        )
      when Case::Events::DidComplete
        return
      when Case::Events::DidSignContract
        Cases::AttachContract.perform_async(
          event.case_id.val,
          event.document_id.val,
        )
      when Case::Events::DidChangeActivity
        Agent::PublishActivity.perform_async(
          event.case_id.val,
          event.case_new_activity,
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
        Chats::PublishMessage.perform_async(
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
      when Chat::Events::DidChangeMessageStatus
        Chats::PublishMessageStatus.perform_async(
          event.message_id.val
        )
      end
    end

    # -- command/helpers
    private def deliver(mail, now: false)
      if now
        mail.deliver_now
      else
        mail.deliver_later
      end
    end
  end
end
