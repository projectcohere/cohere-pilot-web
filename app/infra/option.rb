class Option
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
  def to_sym
    return @key
  end

  def to_s
    return @key.to_s
  end

  def to_i
    return @index
  end

  # -- statics --
  class << self
    def keys
      return all.keys
    end

    def values
      return all.values
    end

    private def all
      return @all.freeze
    end

    # -- statics/factories
    def from_key(key, group: nil)
      return key != nil ? all[resolve_key(key, group)] : nil
    end

    def from_index(i)
      return values[i]
    end

    # -- statics/definition
    def option(key, **props)
      key = resolve_key(key, @group)

      # build option
      option = new(key, @all&.length || 0, **props).freeze

      # store option in map
      @all ||= {}
      @all[key] = option

      # define constant: e.g. `Color::Red`
      const_set(key.to_s.camelcase, option)

      # define predicate method: e.g. `def red?`
      define_method("#{key}?") do
        return @key == key
      end
    end

    def group(name)
      assert(block_given?, "must pass a group block")
      @group = name
      yield
      @group = nil
    end

    # -- statics/helpers --
    private def resolve_key(key, group)
      return group != nil ? :"#{group}_#{key}" : key.to_sym
    end
  end
end
