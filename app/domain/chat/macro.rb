class Chat
  class Macro < ::Entity
    prop(:name)
    prop(:body)
    prop(:attachment, default: nil)
  end
end
