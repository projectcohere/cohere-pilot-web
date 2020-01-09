class Chat
  class Invitation < ::Value
    prop(:token)
    prop(:expires_at)
    props_end!
  end
end
