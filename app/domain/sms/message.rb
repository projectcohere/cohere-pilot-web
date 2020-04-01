module Sms
  class Message < ::Value
    # -- props --
    prop(:phone_number)
    prop(:attachments)
  end
end
