class Case
  class Policy
    # -- lifetime --
    def initialize(user, kase = nil)
      @user = user
      @case = kase
    end

    # -- queries --
    def permit?(action)
      # this can just pattern match in ruby 2.7
      case @user.role
      when :cohere
        true
      when :enroller
        true
      end
    end

    def forbid?(action)
      not permit?(action)
    end
  end
end
