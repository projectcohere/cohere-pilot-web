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
      const_set(key.capitalize, new(key).freeze)

      # define predicate method: e.g. `def red?`
      define_method("#{key}?") do
        return @key == key
      end
    end

    def from_key(key)
      return const_get(key.capitalize)
    end
  end
end
