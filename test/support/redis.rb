module Support
  module Redis
    extend ActiveSupport::Concern

    # -- lifecycle --
    def before_setup
      super
      Services.mock(::Redis, MockRedis.new)
    end

    def after_teardown
      Services.unmock(::Redis)
      super
    end

    # -- mock --
    class MockRedis
      def get(key)
        return storage[key]
      end

      def set(key, value)
        storage[key] = value
      end

      def del(key)
        storage.delete(key)
      end

      def close; end

      # -- helpers --
      private def storage
        @storage ||= {}
      end
    end
  end
end

ActiveSupport::TestCase.include(Support::Redis)
