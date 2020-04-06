class Chat
  class Macro < ::Entity
    prop(:name)
    prop(:body)
    prop(:file, default: nil)
  end
end
