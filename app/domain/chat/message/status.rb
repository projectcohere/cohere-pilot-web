class Chat
  class Message
    class Status
      include ::Options

      # -- options --
      option(:queued)
      option(:failed)
      option(:delivered)
      option(:undelivered)
      option(:received)
    end
  end
end
