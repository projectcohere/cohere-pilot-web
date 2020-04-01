module Twilio
  class Signature
    def initialize(url, params)
      @url = url
      @params = params
    end

    # -- queries --
    def match?(other)
      return ActiveSupport::SecurityUtils.secure_compare(computed, other)
    end

    def computed
      return Base64.strict_encode64(OpenSSL::HMAC.digest(
        OpenSSL::Digest.new("sha1"),
        ENV["TWILIO_API_AUTH_TOKEN"],
        @url + @params.sort.join,
      ))
    end
  end
end
