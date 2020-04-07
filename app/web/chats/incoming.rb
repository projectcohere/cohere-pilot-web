module Chats
  class Incoming < Value
    prop(:id)
    prop(:body)
    prop(:attachment_ids, default: nil)
  end
end
