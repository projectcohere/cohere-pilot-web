class RedisQueue
  # -- lifetime --
  def initialize(key, redis: Redis.current)
    @key = key
    @redis = redis
  end

  # -- commands --
  def <<(event)
    @redis.rpush(@key, event)
  end

  def drain(&block)
    events = @redis.lrange(@key, 0, -1)
    @redis.del(@key)
    events.each(&block)
  end
end
