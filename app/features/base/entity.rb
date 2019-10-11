class Entity
  class << self
    alias_method(:prop, :attr_reader)
  end
end
