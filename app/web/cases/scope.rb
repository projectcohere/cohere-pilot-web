module Cases
  class Scope
    include ::Options

    # -- options --
    option(:assigned)
    option(:queued)
    option(:all)
    option(:open)
    option(:submitted)
    option(:completed)

    # -- queries --
    def title
      return case self
      when Assigned
        "My Cases"
      when Queued
        "Available Cases"
      else
        "#{@key.capitalize} Cases"
      end
    end

    def name
      return case self
      when Assigned
        "My Cases"
      when Queued
        "Queue"
      else
        "#{@key.capitalize}"
      end
    end

    def adjective
      return @key
    end
  end
end
