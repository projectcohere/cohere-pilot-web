class DemoStore
  def initialize
    @store = {}
  end

  def execute
    yield(self)
  end

  def get(key)
    return @store[key]
  end

  def set(key, value)
    @store[key] = value
  end
end
