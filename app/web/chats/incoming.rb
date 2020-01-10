module Chats
  class Incoming < Value
    prop(:body)
    prop(:attachment_ids)
    props_end!
  end
end
