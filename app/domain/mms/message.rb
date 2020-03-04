module Mms
  class Message < ::Value
    prop(:sender_phone_number)
    prop(:receiver_phone_number)
    prop(:attachments)

    # -- queries --
    def recipient_phone_number
      if @sender_phone_number != ENV["FRONT_API_PHONE_NUMBER"]
        return @sender_phone_number
      else
        return @receiver_phone_number
      end
    end

    def sent_by?(phone_number)
      return @sender_phone_number == phone_number
    end
  end
end
