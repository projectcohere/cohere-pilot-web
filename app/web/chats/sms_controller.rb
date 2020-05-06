module Chats
  class SmsController < ApplicationController
    protect_from_forgery(
      except: %i[inbound status]
    )

    before_action(:check_signature!,
      only: %i[inbound status]
    )

    # -- actions --
    def inbound
      sms = Twilio::DecodeSms.(request.POST)
      AddSmsMessage.(sms)
    end

    def status
      sms = Twilio::DecodeSms.(request.POST)
      ChangeMessageStatus.(sms)
    end

    # -- filters --
    def check_signature!
      signature = Twilio::Signature.new(request.url, request.POST)

      if not signature.match?(request.headers["X-Twilio-Signature"])
        return head(:forbidden)
      end
    end
  end
end
