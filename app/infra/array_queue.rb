class ArrayQueue
  include Enumerable

  # -- lifetime --
  def initialize
    @queue = []
  end

  def initialize_copy(other)
    @queue = @queue.clone
  end

  # -- commands --
  def add(event)
    @queue.push(event)
  end

  def add_unique(event)
    @queue.delete(event)
    @queue.push(event)
  end

  def drain(&block)
    @queue.reject! do |event|
      block.(event)
      true
    end
  end

  def consume(other)
    other.drain do |event|
      @queue << event
    end
  end

  def clear
    @queue.clear
  end

  # -- queries --
  def [](index)
    return @queue[index]
  end

  def length
    return @queue.length
  end

  # -- Enumerable --
  def each(&block)
    return @queue.each(&block)
  end

  # -- constants --
  Empty = ArrayQueue.new
end
