class User
  class Invitation < ::Value
    prop(:email)
    prop(:role)
    props_end!
  end
end
