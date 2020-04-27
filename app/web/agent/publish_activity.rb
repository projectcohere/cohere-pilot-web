module Agent
  class PublishActivity < ApplicationWorker
    # -- lifetime --
    def initialize(partner_repo: Partner::Repo.get)
      @partner_repo = partner_repo
    end

    # -- command --
    def call(case_id, case_new_activity)
      channel = Cases::ActivityChannel
      channel.broadcast_to(
        channel.role_stream(
          Role::Agent,
          @partner_repo.find_cohere.id,
        ),
        Cases::ActivityEvent.has_new_activity(
          case_id,
          case_new_activity,
        ),
      )
    end
  end
end
