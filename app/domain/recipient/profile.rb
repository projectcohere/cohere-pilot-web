module Recipient
  class Profile < ::Value
    # -- props --
    prop(:name)
    prop(:address)
    prop(:phone)
    props_end!
  end
end
