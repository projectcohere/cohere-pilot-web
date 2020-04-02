module Support
  module Channels
    # -- queries --
    def case_activity_for(partner_name)
      partner_rec = partners(partner_name)
      return Cases::ActivityChannel::broadcasting_for(partner_rec.id)
    end

    def chat_messages_for(chat_name)
      chat_rec = chats(chat_name)
      return Chats::MessageChannel::broadcasting_for(chat_rec.id)
    end

    # -- asserts --
    def assert_matching_broadcast_on(stream)
      assert(block_given?, "expected a matching block for `assert_matching_broadcast_on")

      messages = broadcasts(stream)
      assert(messages.length > 0, "expected at least one broadcast")

      has_match = messages.any? do |msg|
        begin
          yield(ActiveSupport::JSON.decode(msg))
        rescue Minitest::Assertion
          false
        else
          true
        end
      end

      assert(has_match, "exepcted a message to match the block")
    end

    def assert_broadcasts_on(stream, count)
      assert_broadcasts(stream, count)

      encoded = broadcasts(broadcasting_for(stream))
      decoded = encoded.map { |e| ActiveSupport::JSON.decode(e) }

      if block_given?
        yield(decoded)
      end
    end
  end
end

ActiveSupport::TestCase.include(Support::Channels)
