module Service
  # dsl methods for the Service::Container; extracted into a module to
  # avoid distracting from the definitions themselves
  module Definition
    extend ActiveSupport::Concern

    class_methods do
      # -- queries --
      def get(name_or_type)
        return public_send(get_name(name_or_type))
      end

      def get_name(name_or_type)
        name = name_or_type

        if name_or_type.is_a?(Module)
          name = name_or_type.name.underscore.gsub("/", "_")
        end

        return name.to_sym
      end

      # -- scoping --
      def builds(name_or_type, &factory)
        assert(factory != nil || name_or_type.is_a?(Module), "must pass a type or a factory")

        name = get_name(name_or_type)
        attribute(name)
        define_factory(name, factory || -> { name_or_type.new })
      end

      def single(name_or_type, &factory)
        assert(factory != nil || name_or_type.is_a?(Module), "must pass a type or a factory")

        name = get_name(name_or_type)
        attribute(name)
        define_single_factory(name, factory || -> { name_or_type.new })
      end

      # -- scoping/helpers
      private def define_factory(name, factory)
        define_method(name) do
          super() || factory.()
        end
      end

      private def define_single_factory(name, factory)
        define_method(name) do
          service = super()

          if service == nil
            service = factory.()
            public_send("#{name}=", service)
          end

          service
        end
      end
    end
  end
end
