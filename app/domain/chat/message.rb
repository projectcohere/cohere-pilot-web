class Chat
  class Message < ::Entity
    prop(:id, default: 0)
    prop(:type)
    prop(:body)
    prop(:sender)
    props_end!
  end
end
