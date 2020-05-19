module Reports
  class Policy < ::Policy
    # -- queries --
    def permit?(action)
      case action
      # -- list
      when :list_accounting
        permit?(:view_accounting)
      when :list_programs
        permit?(:view_program)

      # -- view
      when :view_accounting
        agent?
      when :view_program
        agent? || enroller?

      else
        super
      end
    end
  end
end
