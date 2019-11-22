# Internal storage for shared repos. Get a service using its class-level
# accessor, e.g. `Case::Repo.get`.
class Services < ActiveSupport::CurrentAttributes
  # -- web --
  attribute(:tracking_events)

  def tracking_events
    service = super

    if service.nil?
      service = RedisQueue.new("tracking-events")
      self.tracking_events = service
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
