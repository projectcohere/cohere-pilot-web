class Case
  class Status < ::Option
    # -- options --
    option(:opened)
    option(:submitted)
    option(:returned)
    option(:approved)
    option(:denied)
    option(:removed)

    # -- queries --
    def complete?
      return approved? || denied? || removed?
    end
  end
end
