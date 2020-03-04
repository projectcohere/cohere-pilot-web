module Mms
  class Message < ::Value
    prop(:sender)
    prop(:attachments)

    # -- queries --
    def sent_by?(phone_number)
      return @sender.phone_number == phone_number
    end
  end
end
