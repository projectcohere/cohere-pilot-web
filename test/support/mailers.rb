module Support
  module Mailers
    def send_all_emails!
      perform_enqueued_jobs(queue: :mailers)
    end
  end
end

ActiveSupport::TestCase.include(Support::Mailers)
