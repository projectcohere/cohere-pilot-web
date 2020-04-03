module Support
  module Services
    # -- lifecycle --
    def before_setup
      super
      Service::Container.reset
    end

    # -- mocking --
    def self.mock
      Service::Container.resets do
        yield(Service::Container)
      end
    end
  end
end

ActiveSupport::TestCase.include(Support::Services)
