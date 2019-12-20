class Chat
  class Token < ::Value
    prop(:val)
    prop(:expires_at)
    props_end!
  end
end
