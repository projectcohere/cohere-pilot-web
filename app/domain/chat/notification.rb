class Chat
  class Notification < ::Value
    prop(:recipient_name)
    props_end!

    # -- queries --
    def text
      return nil
    end
  end
end
