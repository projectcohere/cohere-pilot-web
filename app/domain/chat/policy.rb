class Chat
  class Policy < ::Policy
    # -- lifetime --
    def initialize(user, chat = nil)
      @chat = chat
      super(user)
    end

    # -- queries --
    # checks if the given user/case is allowed to perform an action.
    def permit?(action)
      # then check action permissions
      case action
      when :files
        cohere?
      else
        false
      end
    end
  end
end
