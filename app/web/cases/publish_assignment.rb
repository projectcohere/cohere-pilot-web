module Cases
  class PublishAssignment < ApplicationWorker
    # -- command --
    def call(case_id, partner_id)
      Cases::ActivityChannel.broadcast_to(
        partner_id,
        Cases::ActivityEvent.did_assign_user(
          case_id,
        ),
      )
    end

    alias :perform :call
  end
end
