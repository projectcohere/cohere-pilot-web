class Message < ::Entity
  # -- factories --
  def self.from_json(_)
    Message.new
  end
end
