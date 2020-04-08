module Chats
  class MessagesEvent < ::Value
    # -- props --
    prop(:name)
    prop(:data)

    # -- events --
    def self.did_save_message(inbound, message)
      return MessagesEvent.new(
        name: "DID_SAVE_MESSAGE",
        data: {
          client_id: inbound.client_id,
          id: message.id.val,
        }
      )
    end

    def self.did_add_message(message)
      return MessagesEvent.new(
        name: "DID_ADD_MESSAGE",
        data: EncodeMessage.(message)
      )
    end

    def self.has_new_status(message)
      return MessagesEvent.new(
        name: "HAS_NEW_STATUS",
        data: {
          id: message.id.val,
          status: message.status.index,
        },
      )
    end
  end
end
