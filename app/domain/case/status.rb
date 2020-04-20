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
    def self.all
      @all ||= [
        Opened,
        Pending,
        Submitted,
        Approved,
        Denied,
        Removed
      ]
    end

    def self.opened?(status)
      return status == Status::Opened
    end

    def self.pending?(status)
      return status == Status::Pending
    end

    def self.submitted?(status)
      return status == Status::Submitted
    end

    def self.approved?(status)
      return status == Status::Approved
    end

    def self.denied?(status)
      return status == Status::Denied
    end

    def self.removed?(status)
      return status == Status::Removed
    end

    def self.active?(status)
      return opened?(status) || pending?(status) || submitted?(status)
    end

    def self.complete?(status)
      return status != nil && !active?(status)
    end
  end
end
