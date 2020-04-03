class Command
  # -- includes --
  include Service

  # -- command --
  def self.call(*args)
    return get.(*args)
  end
end
