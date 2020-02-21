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
  def <<(event)
    @queue << event
  end

  def drain(&block)
    @queue.reject! do |event|
      block.(event)
      true
    end
  end

  def consume(events)
    events.drain do |event|
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
