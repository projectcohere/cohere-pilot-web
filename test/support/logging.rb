module Support
  module Logging
    # -- test utilities --
    def fake_logging!
      logger = Logger.new
      @original = Rails.logger
      Rails.logger = logger
      logger
    end

    # -- test lifecycle --
    def before_teardown
      if not @original.nil?
        Rails.logger = @original
        @original = nil
      end
    end

    # -- Logger --
    class Logger
      def initialize
        @messages = []
      end

      def info(message = "")
        @messages << message
      end

      def debug(message = "")
        @messages << message
      end

      def messages
        @messages
      end
    end
  end
end

ActiveSupport::TestCase.include(Support::Logging)
