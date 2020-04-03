module Cases
  class PublishUnassignUser < ApplicationWorker
    # -- command --
    def call(case_id, partner_id)
      Cases::ActivityChannel.broadcast_to(
        partner_id,
        Cases::ActivityEvent.did_unassign_user(
          case_id,
        ),
      )
    end
  end
end
