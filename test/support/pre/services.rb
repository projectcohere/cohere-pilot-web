module Support
  module Services
    # -- lifecycle --
    def before_setup
      super
      ::Services.reset
    end

    # -- mocking --
    def self.mock
      ::Services.resets do
        yield(::Services)
      end
    end
  end
end

ActiveSupport::TestCase.include(Support::Services)
