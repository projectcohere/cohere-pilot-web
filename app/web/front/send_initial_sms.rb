module Front
  class SendInitialSms < ::Command
    # -- lifetime --
    def self.get
      SendInitialSms.new
    end

    def initialize(front: Client.get)
      @front = front
    end

    # -- command --
    def call(phone_number, body)
      json = @front.post("/channels/#{ENV["FRONT_API_CHANNEL_ID"]}/messages", {
        "to" => ["+1#{phone_number}"],
        "body" => body,
        "options" => {
          "archive" => false
        }
      })

      # parse json
      conversation_id = json&.dig("_links", "related", "conversation")&.split("/")&.last

      return conversation_id
    end
  end
end
