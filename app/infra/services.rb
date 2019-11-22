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

    service
  end

  # -- domain --
  attribute(:domain_events)

  def domain_events
    service = super

    if service.nil?
      service = ArrayQueue.new
      self.domain_events = service
    end

    service
  end

  # -- domain/repos
  attribute(:user_repo)
  attribute(:enroller_repo)
  attribute(:supplier_repo)
end
