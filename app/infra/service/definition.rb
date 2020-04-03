module Service
  # dsl methods for the Service::Container; extracted into a module to
  # avoid distracting from the definitions themselves
  module Definition
    extend ActiveSupport::Concern

    class_methods do
      # -- queries --
      def get(name_or_type)
        return public_send(name_from(name_or_type))
      end

      # -- definition --
      def singleton(name_or_type, &factory)
        name = name_from(name_or_type)

        # define CurrentAttributes.attribute
        attribute(name)

        # synthesize lazy singleton accessor
        define_method(name) do
          service = super()

          if service == nil
            service = factory != nil ? factory.() : name_or_type.new
            public_send("#{name}=", service)
          end

          service
        end
      end

      # -- helpers --
      private def name_from(name_or_type)
        return name_or_type.is_a?(Module) ? name_or_type.name.underscore : name_or_type
      end
    end
  end
end
