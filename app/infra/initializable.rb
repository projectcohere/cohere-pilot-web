module Initializable
  Required = "Required".freeze

  # -- modules --
  extend ActiveSupport::Concern

  # -- definition --
  class_methods do
    def read(name)
      attr_reader(name)
    end

    def prop(name, default: Required)
      props[name] = default
      read(name)
    end

    # -- definition/storage
    def props
      return @props ||= {}
    end

    def finalize_props!
      return props.freeze
    end
  end

  def initialize(**kwargs)
    super()

    # get props and attrs
    props = self.class.finalize_props!
    attrs = kwargs.clone

    # set a value for each key in props
    props.each do |key, default|
      value = if attrs.has_key?(key)
        attrs.delete(key)
      elsif default == Required
        raise_missing_attrs!(key)
      else
        default.clone
      end

      instance_variable_set("@#{key}", value)
    end

    # throw an error if there unknown attrs leftover
    if attrs.count != 0
      raise_unknown_attrs!(props, attrs)
    end
  end

  private def raise_missing_attrs!(key)
    raise(ArgumentError, "missing attr: #{key}")
  end

  private def raise_unknown_attrs!(props, attrs)
    raise(ArgumentError, "unknown attrs: #{attrs.keys - props.keys}")
  end

  private def find_missing_attrs(props, attrs)
    missing_props = []

    props.each do |key, default|
      if default == Required && !attrs.has_key?(key)
        missing_props << key
      end
    end

    return missing_props
  end
end
