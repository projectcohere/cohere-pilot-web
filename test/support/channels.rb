module Support
  module Channels
    # -- asserts --
    def assert_broadcasts_on(name, count)
      assert_broadcasts(name, count)

      encoded = broadcasts(broadcasting_for(name))
      decoded = encoded.map { |e| ActiveSupport::JSON.decode(e) }

      if block_given?
        yield(decoded)
      end
    end
  end
end

ActiveSupport::TestCase.include(Support::Channels)
