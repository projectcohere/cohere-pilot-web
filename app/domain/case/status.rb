class Case
  class Status < ::Option
    # -- options --
    option(:opened)
    option(:pending)
    option(:submitted)
    option(:approved)
    option(:denied)
    option(:removed)

    # -- queries --
    def active?
      return opened? || pending? || submitted?
    end

    def complete?
      return !active?
    end
  end
end
