require "net/http"

module Twilio
  class Client
    include ::Logging

    # -- lifetime --
    def self.get
      return Client.new("https://api.twilio.com/2010-04-01/Accounts/#{ENV["TWILIO_API_ACCOUNT_SID"]}")
    end

    def initialize(host)
      @host = host
    end

    # -- commands --
    def get(path_or_url)
      req = Net::HTTP::Get.new(uri(path_or_url))
      res = start(auth(req))

      while res.redirect?
        req = Net::HTTP::Get.new(res.redirect_uri)
        res = start(auth(req))
      end

      return res
    end

    def post(path_or_url, params)
      req = Net::HTTP::Post.new(uri(path_or_url))
      req.body = URI.encode_www_form(params)
      return start(auth(req))
    end

    # -- commands/helpers
    private def uri(path_or_url)
      if path_or_url.start_with?(@host)
        return URI(path_or_url)
      else
        return URI("#{@host}#{path_or_url}")
      end
    end

    private def auth(req)
      if req.uri.to_s.start_with?(@host)
        req.basic_auth(ENV["TWILIO_API_ACCOUNT_SID"], ENV["TWILIO_API_AUTH_TOKEN"])
      end

      return req
    end

    private def start(req, json: false)
      Net::HTTP.start(req.uri.host, req.uri.port, use_ssl: true) do |http|
        log.debug { "#{self.class.name}:#{__LINE__} req -- #{req.uri}?#{req.body}"}
        res = Response.new(http.request(req))
        log.debug { "#{self.class.name}:#{__LINE__} res --\n#{res.json || res.message}"}
        res
      end
    end
  end

  # -- children --
  class Response
    # -- lifetime --
    def initialize(res)
      @res = res
    end

    # -- queries --
    # -- queries/data
    def message
      return @res.message
    end

    def body
      return @res.body
    end

    def json
      if success? && body != nil
        return @json ||= ActiveSupport::JSON.decode(body)
      end
    end

    # -- queries/status
    def success?
      return @res.kind_of?(Net::HTTPSuccess)
    end

    def redirect?
      return @res.kind_of?(Net::HTTPRedirection)
    end

    # -- queries/meta
    def redirect_uri
      return @res["Location"]&.then { |l| URI(l) }
    end

    def content_type
      return @res.content_type
    end

    def filename
      return @res["Content-Disposition"][/filename="([^"]+)"/, 1]
    end
  end
end
