class Case
  class Policy
    # -- lifetime --
    def initialize(user, kase = nil)
      @user = user
      @case = kase
    end

    # -- queries --
    def permit?(action)
      role = @user.role

      # this can pattern match on [action, role] in ruby 2.7
      case action
      when :list
        role != :supplier
      when :edit
        role != :supplier
      when :create
        role == :supplier
      when :view_status
        role == :cohere
      else
        false
      end
    end

    def forbid?(action)
      not permit?(action)
    end

    # -- commands --
    def with_record(kase)
      previous = @case
      @case = kase
      result = yield
      @case = previous
      result
    end
  end
end
