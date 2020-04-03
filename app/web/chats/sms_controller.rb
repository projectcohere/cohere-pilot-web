module Chats
  class SmsController < ApplicationController
    protect_from_forgery(
      except: :twilio
    )

    # -- actions --
    def twilio
      signature = Twilio::Signature.new(request.url, request.POST)
      if not signature.match?(request.headers["X-Twilio-Signature"])
        return head(:forbidden)
      end

      sms = Twilio::DecodeSms.(request.POST)
      AddSmsMessage.(sms)
    end
  end
end
