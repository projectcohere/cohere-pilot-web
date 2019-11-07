class User < ::Entity
  # -- props --
  prop(:id)
  prop(:email)
  prop(:role)
  prop(:organization, default: nil)
  props_end!
end
