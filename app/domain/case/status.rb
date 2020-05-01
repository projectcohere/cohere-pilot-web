class Case
  # TODO: derive this from ::Option
  module Status
    # -- options --
    Opened = :opened
    Pending = :pending
    Submitted = :submitted
    Approved = :approved
    Denied = :denied
    Removed = :removed

    # -- queries --
    class << self
      def all
        @all ||= [
          Opened,
          Pending,
          Submitted,
          Approved,
          Denied,
          Removed
        ]
      end

      alias :keys :all

      def opened?(status)
        return status == Status::Opened
      end

      def pending?(status)
        return status == Status::Pending
      end

      def submitted?(status)
        return status == Status::Submitted
      end

      def approved?(status)
        return status == Status::Approved
      end

      def denied?(status)
        return status == Status::Denied
      end

      def removed?(status)
        return status == Status::Removed
      end

      def active?(status)
        return opened?(status) || pending?(status) || submitted?(status)
      end

      def complete?(status)
        return status != nil && !active?(status)
      end
    end
  end
end
