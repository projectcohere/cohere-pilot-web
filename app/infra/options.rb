module Options
  extend ActiveSupport::Concern

  # -- props --
  attr(:key)

  # -- liftime --
  def initialize(key)
    @key = key
  end

  # -- definition --
  class_methods do
    def option(key)
      # define constant
      value = const_set(key.capitalize, new(key).freeze)

      # store key -> value map
      @all ||= {}
      @all[key] = value

      # define predicate method: e.g. `def red?`
      define_method("#{key}?") do
        return @key == key
      end
    end

    def from_key(key)
      return @all[key]
    end

    def keys
      return @all.keys
    end

    def values
      return @all.values
    end
  end
end
