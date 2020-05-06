module Chats
  class InboundMessage < Value
    prop(:client_id)
    prop(:body)
    prop(:attachment_ids, default: nil)
  end
end
