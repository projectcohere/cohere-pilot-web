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

  # call the block for each event in the queue at call time, only
  # removing it if successful
  def drain(&block)
    @redis.llen(@key).times do
      event = @redis.lrange(@key, 0, 0).first
      block.(event)
      @redis.lpop(@key)
    end
  end
end
