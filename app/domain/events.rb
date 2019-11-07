class Events
  # -- lifetime --
  def self.get
    Services.events ||= Events.new
  end

  def initialize
    @queue = []
  end

  # -- commands --
  def <<(event)
    @queue << event
  end

  # -- queries --
  def consume(&block)
    @queue.reject!(&block)
  end
end
