module Cases
  class PublishUnassignUser < ApplicationWorker
    # -- command --
    def call(case_id, partner_id, role)
      channel = Cases::ActivityChannel
      channel.broadcast_to(
        channel.role_stream(role, partner_id),
        Cases::ActivityEvent.did_unassign_user(
          case_id,
        ),
      )
    end
  end
end
