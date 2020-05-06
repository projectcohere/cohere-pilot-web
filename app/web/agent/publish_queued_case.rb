module Agent
  class PublishQueuedCase < ApplicationWorker
    # -- lifetime --
    def initialize(partner_repo: Partner::Repo.get)
      @partner_repo = partner_repo
    end

    # -- command --
    def call(case_id)
      channel = Cases::ActivityChannel
      channel.broadcast_to(
        channel.role_stream(
          Role::Agent,
          @partner_repo.find_cohere.id,
        ),
        Cases::ActivityEvent.did_add_queued_case(
          case_id,
        ),
      )
    end
  end
end
