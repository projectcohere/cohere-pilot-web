class Chat
  class Token < ::Value
    prop(:value)
    prop(:expires_at)
    props_end!
  end
end
