module Cases
  class Action < ::Option
    option(:submit)
    option(:approve)
    option(:deny)
    option(:remove)

    # -- queries --
    def complete?
      return approve? || deny?
    end
  end
end
