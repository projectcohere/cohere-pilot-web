module Sms
  class Message < ::Value
    prop(:id)
    prop(:phone_number)
    prop(:body)
    prop(:media)
    prop(:status)
  end
end
