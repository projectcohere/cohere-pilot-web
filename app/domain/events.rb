class Events
  # -- lifetime --
  def self.get
    Services.events ||= Events.new
  end

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

  # -- queries --
  def [](index)
    @queue[index]
  end

  def length
    @queue.length
  end

  # -- constants --
  Empty = Events.new
end
