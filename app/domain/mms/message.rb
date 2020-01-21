module Mms
  class Message < ::Value
    prop(:sender)
    prop(:attachments)
    props_end!

    # -- children --
    class Sender < ::Value
      prop(:phone_number)
      props_end!
    end

    class Attachment < :: Entity
      prop(:url)
      props_end!
    end
  end
end
