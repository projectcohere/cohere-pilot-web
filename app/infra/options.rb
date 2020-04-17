module Options
  extend ActiveSupport::Concern

  include ::Initializable

  # -- props --
  attr(:key)
  attr(:index)

  # -- lifetime --
  def initialize(key, index, **props)
    @key = key
    @index = index
    super(**props)
  end

  # -- queries --
  def to_s
    return @key.to_s
  end

  # -- statics --
  class_methods do
    # -- definition --
    def option(key, **props)
      @all ||= {}

      # build option
      option = @all[key] = new(key, @all.length, **props).freeze

      # define constant: e.g. `Color::Red`
      const_set(key.capitalize, option)

      # define predicate method: e.g. `def red?`
      define_method("#{key}?") do
        return @key == key
      end
    end

    # -- queries --
    def keys
      return @all.keys
    end

    def values
      return @all.values
    end

    # -- factories --
    def from_key(key)
      return key != nil ? @all[key.to_sym] : nil
    end

    def from_index(i)
      return values[i]
    end
  end
end
