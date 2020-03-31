require "net/http"

module Twilio
  class Client
    include ::Logging

    # -- liftime --
    def self.get
      return Client.new("https://api.twilio.com/2010-04-01/Accounts/#{ENV["TWILIO_API_ACCOUNT_SID"]}")
    end

    def initialize(host)
      @host = host
    end

    # -- commands --
    def post(endpoint, params)
      uri = URI("#{@host}#{endpoint}")

      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        req = Net::HTTP::Post.new(uri)
        req.basic_auth(ENV["TWILIO_API_ACCOUNT_SID"], ENV["TWILIO_API_AUTH_TOKEN"])
        req.body = URI.encode_www_form(params)

        log.debug { "#{self.class.name}:#{__LINE__} req -- #{req.uri}?#{req.body}"}

        res = http.request(req)
        res_json = if res.kind_of?(Net::HTTPSuccess) && res.body != nil
          ActiveSupport::JSON.decode(res.body)
        end

        log.debug { "#{self.class.name}:#{__LINE__} res --\n#{res_json || res.message}"}

        res_json
      end
    end
  end
end
