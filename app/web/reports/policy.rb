module Reports
  class Policy < ::Policy
    # -- queries --
    def permit?(action)
      case action
      # -- new
      when :create_internal
        false
      when :create_programs
        agent? || enroller?
      else
        super
      end
    end
  end
end
