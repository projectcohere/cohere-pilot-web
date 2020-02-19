module Front
  class SendSms < ::Command
    # -- lifetime --
    def self.get
      SendSms.new
    end

    def initialize(front: Client.get)
      @front = front
    end

    # -- command --
    def call(conversation_id, body)
      @front.post("/conversations/#{conversation_id}/messages", {
        "body" => body,
      })

      return nil
    end
  end
end
