class Settings
  include Service

  # -- lifetime --
  def initialize(redis: Service::Container.redis)
    @redis = redis
  end

  # -- hours --
  WorkingHoursKey = "cohere/settings/working-hours".freeze
  WorkingHoursFlag = "true".freeze

  def working_hours?
    return get(WorkingHoursKey) == WorkingHoursFlag
  end

  def working_hours=(value)
    set(WorkingHoursKey, value ? WorkingHoursFlag : nil)
  end

  # -- helpers --
  private def get(key)
    return @redis.get(key)
  end

  private def set(key, value)
    if value
      @redis.set(key, value)
    else
      @redis.del(key)
    end
  end
end
