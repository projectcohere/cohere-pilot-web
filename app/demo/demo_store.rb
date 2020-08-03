class DemoStore
  def initialize
    @store = {}
  end

  def execute
    yield
  end

  def get(key)
    return @store[key]
  end

  def set(key, value)
    @store[key] = value
  end
end
