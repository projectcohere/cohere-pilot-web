class Chat < Entity
  # -- props --
  prop(:id, default: Id::None)
  prop(:recipient_token, default: nil)
  props_end!
end
