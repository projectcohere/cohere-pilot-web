module Service
  class Container < ActiveSupport::CurrentAttributes
    # -- includes --
    include Service::Definition

    # -- services --
    # -- services/web
    single(:analytics_events) do
      RedisQueue.new("analytics--events")
    end

    # -- services/domain
    single(:domain_events) do
      ArrayQueue.new
    end

    single(Events::DispatchAll)

    single(User::Repo)
    single(Partner::Repo)

    # -- services/infra
    single(Redis)
  end
end
