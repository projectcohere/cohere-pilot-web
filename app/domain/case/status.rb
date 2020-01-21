class Case
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
  end
end
