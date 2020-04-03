class Command
  def self.get
    return new
  end

  def self.call(*args)
    return get.(*args)
  end
end
