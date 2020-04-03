module Sms
  class Message < ::Value
    prop(:phone_number)
    prop(:body)
    prop(:media)
  end
end
