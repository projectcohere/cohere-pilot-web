require "net/http"

module Chats
  class SendInvite < ::Command
    # -- command --
    def call(phone_number)
      uri = URI("https://verify.twilio.com/v2/Services/#{ENV["TWILIO_INVITE_SID"]}/Verifications")

      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        req = Net::HTTP::Post.new(uri)
        req.basic_auth(ENV["TWILIO_INVITE_API_KEY"], ENV["TWILIO_INVITE_API_SECRET"])
        req.body = URI.encode_www_form({
          "To" => "+1#{phone_number}",
          "Channel" => "sms",
        })

        res = http.request(req)
        res.kind_of?(Net::HTTPSuccess)
      end
    end
  end
end
