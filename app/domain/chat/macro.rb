class Chat
  class Macro < ::Value
    prop(:name)
    prop(:body)
    prop(:file, default: nil)
  end
end
