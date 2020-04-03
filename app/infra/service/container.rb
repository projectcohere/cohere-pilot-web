module Service
  class Container < ActiveSupport::CurrentAttributes
    # -- includes --
    include Service::Definition

    # -- services --
    # -- services/web
    singleton(:analytics_events) do
      RedisQueue.new("analytics--events")
    end

    # -- services/domain --
    singleton(:domain_events) do
      ArrayQueue.new
    end

    # -- infra --
    singleton(Redis)
  end
end
