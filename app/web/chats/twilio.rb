module Chats
  class Twilio
    # -- liftime --
    def self.get
      Twilio.new
    end

    # -- commands --
    def post(endpoint, params)
      uri = URI("https://verify.twilio.com/v2/Services/#{ENV["TWILIO_API_VERIFY_SID"]}#{endpoint}")

      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        req = Net::HTTP::Post.new(uri)
        req.basic_auth(ENV["TWILIO_API_KEY"], ENV["TWILIO_API_SECRET"])
        req.body = URI.encode_www_form(params)

        res = http.request(req)
        if res.kind_of?(Net::HTTPSuccess) && res.body != nil
          ActiveSupport::JSON.decode(res.body)
        end
      end
    end
  end
end
