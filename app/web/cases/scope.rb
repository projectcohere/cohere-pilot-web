module Cases
  class Scope < ::Option
    # -- options --
    option(:assigned)
    option(:queued)
    option(:all)
    option(:active)
    option(:archived)

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
      return case self
      when All
        nil
      else
        @key
      end
    end
  end
end
