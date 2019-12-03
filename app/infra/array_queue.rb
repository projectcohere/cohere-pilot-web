class ArrayQueue
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
    @queue[index]
  end

  def length
    @queue.length
  end

  # -- constants --
  Empty = ArrayQueue.new
end
