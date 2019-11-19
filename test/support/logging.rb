module Support
  module Logging
    def fake_logging!
      logger = Logger.new
      @original = Rails.logger
      Rails.logger = logger
      logger
    end

    def reset_logging!
      Rails.logger = @original
      @original = nil
    end

    # -- Logger --
    class Logger
      def initialize
        @messages = []
      end

      def info(message = "")
        @messages << message
      end

      def messages
        @messages
      end
    end
  end
end

ActiveSupport::TestCase.include(Support::Logging)
