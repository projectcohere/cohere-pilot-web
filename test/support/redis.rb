module Support
  module Redis
    class MockRedis
      def get(key)
        return storage[key]
      end

      def set(key, value)
        storage[key] = value
      end

      private def storage
        @storage ||= {}
      end
    end

    # -- mocks --
    Services.mock do |s|
      s.redis = MockRedis.new
    end
  end
end

ActiveSupport::TestCase.include(Support::Redis)
