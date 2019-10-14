class Case
  class Policy
    # -- lifetime --
    def initialize(user, kase = nil)
      @user = user
      @case = kase
    end

    # -- queries --
    def permit?(action)
      # this can pattern match on [action, user.role] in ruby 2.7
      case action
      when :list
        true
      when :show
        true
      when :view_status
        @user.role == :cohere
      else
        false
      end
    end

    def forbid?(action)
      not permit?(action)
    end
  end
end
