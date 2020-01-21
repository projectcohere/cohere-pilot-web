module Support
  module Io
    def with_stdin(io)
      ostdin = $stdin
      $stdin = io
      yield
    ensure
      $stdin = ostdin
    end
  end
end

ActiveSupport::TestCase.include(Support::Io)
