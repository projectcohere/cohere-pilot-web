module Cases
  class PublishAssignUser < ApplicationWorker
    # -- command --
    def call(case_id, partner_id, role)
      channel = Cases::ActivityChannel
      channel.broadcast_to(
        channel.role_stream(role, partner_id),
        Cases::ActivityEvent.did_assign_user(
          case_id,
        ),
      )
    end
  end
end
