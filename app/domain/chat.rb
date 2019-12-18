class Chat < Entity
  # -- props --
  prop(:id, default: Id::None)
  prop(:remember_token, default: nil)
  props_end!
end
