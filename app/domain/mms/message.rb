module Mms
  class Message < ::Value
    prop(:sender)
    prop(:attachments)

    # -- children --
    class Sender < ::Value
      prop(:phone_number)
    end

    class Attachment < :: Entity
      prop(:url)
    end
  end
end
