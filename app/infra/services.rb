# Internal storage for shared repos. Get a service using its class-level
# accessor, e.g. `Case::Repo.get`.
class Services < ActiveSupport::CurrentAttributes
  # -- web --
  attribute(:analytics_events)

  def analytics_events
    service = super

    if service.nil?
      service = RedisQueue.new("analytics--events")
      self.analytics_events = service
    end

    return service
  end

  # -- domain --
  attribute(:domain_events)

  def domain_events
    service = super

    if service.nil?
      service = ArrayQueue.new
      self.domain_events = service
    end

    return service
  end

  # -- domain/repos
  attribute(:user_repo)
  attribute(:partner_repo)
  attribute(:supplier_repo)

  # -- infra --
  attribute(:redis)

  def redis
    service = super

    if service.nil?
      service = Redis.new
      self.redis = service
    end

    return service
  end
end
