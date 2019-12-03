module Support
  module Mailers
    # -- commands --
    def send_all_emails!
      perform_enqueued_jobs(queue: :mailers)
    end

    # -- asserts --
    def assert_send_emails(count, &block)
      send_all_emails!
      assert_emails(count)

      if block_given?
        assert_select_email(&block)
      end
    end
  end
end

ActiveSupport::TestCase.include(Support::Mailers)
