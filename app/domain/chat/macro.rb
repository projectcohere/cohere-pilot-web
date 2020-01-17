class Chat
  class Macro < ::Entity
    prop(:name)
    prop(:body)
    prop(:attachment, default: nil)
    props_end!
  end
end
