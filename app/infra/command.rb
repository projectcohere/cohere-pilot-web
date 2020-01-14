class Command
  def self.call(*args)
    command = self.new
    command.(*args)
  end
end
