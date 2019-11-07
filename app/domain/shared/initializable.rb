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
      prop_definitions[name] = default
      read(name)
    end

    def props_end!
      define_initialize!
    end

    def define_initialize!
      @prop_definitions.freeze

      # grab all keywords
      props_keywords = @prop_definitions.keys.freeze

      # split all required and default props
      props_required = []
      props_defaults = {}

      @prop_definitions.each do |k, v|
        if v.equal?(Required)
          props_required << k
        else
          props_defaults[k] = v
        end
      end

      props_required.freeze
      props_defaults.freeze

      # synthesize the constructor
      define_method(:initialize) do |**kwargs|
        unknown_keywords = kwargs.keys - props_keywords
        if not unknown_keywords.empty?
          raise(ArgumentError, "unknown keywords: #{unknown_keywords}")
        end

        missing_keywords = props_required - kwargs.keys
        if not missing_keywords.empty?
          raise(ArgumentError, "missing keywords: #{missing_keywords}")
        end

        props_keywords.each do |key|
          value = if kwargs.has_key?(key)
            kwargs[key]
          else
            props_defaults[key].clone
          end

          instance_variable_set("@#{key}", value)
        end
      end
    end

    # -- definition/storage
    def prop_definitions
      @prop_definitions ||= {}
    end
  end
end
