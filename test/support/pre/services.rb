module Support
  module Services
    def before_setup
      super
      Service::Container.reset
    end

    # -- commands --
    class << self
      def mocks
        @mocks ||= {}
      end

      def mock(name_or_type, mock)
        name = get_name(name_or_type)
        mocks[name] = mock
        Service::Container.attributes[name] = mock
      end

      def unmock(name_or_type)
        mocks.delete(get_name(name_or_type))
      end

      private def get_name(name_or_type)
        return Service::Container.get_name(name_or_type)
      end
    end

    # -- installation --
    s = self
    Service::Container.after_reset do
      attributes.merge!(s.mocks)
    end
  end

  # monkey patch to ensure container always has up-to-date mocks. instances
  # created for new threads don't run their resets automatically.
  module Container
    def new
      instance = super
      instance.reset
      return instance
    end
  end

  Service::Container.extend(Container)
end

ActiveSupport::TestCase.include(Support::Services)
