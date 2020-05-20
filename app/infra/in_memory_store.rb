# Redis wrapper that only allows store interaction through transaction
# blocks that automatically manage connections.
class InMemoryStore
  include Service

  # -- commands --
  def execute(&work)
    connection do
      yield(self)
    end
  end

  # -- operations --
  def get(key)
    assert(@redis != nil, "must be in an execute block!")
    return @redis.get(key)
  end

  def set(key, value)
    assert(@redis != nil, "must be in an execute block!")

    if value
      @redis.set(key, value)
    else
      @redis.del(key)
    end
  end

  # -- helpers --
  private def connection
    @redis = Service::Container.redis
    yield
    @redis.close
    @redis = nil
  end
end
