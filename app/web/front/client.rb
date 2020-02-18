require "net/http"

module Front
  class Client
    # -- liftime --
    def self.get
      Client.new
    end

    # -- commands --
    def post(endpoint, params)
      uri = URI("https://api2.frontapp.com#{endpoint}")

      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        req = Net::HTTP::Post.new(uri)
        req["Authorization"] = "Bearer #{ENV["FRONT_API_JWT"]}"
        req["Accept"] = "application/json"
        req["Content-Type"] = "application/json"
        req.body = ActiveSupport::JSON.encode(params)

        res = http.request(req)
        if res.kind_of?(Net::HTTPSuccess) && res.body != nil
          ActiveSupport::JSON.decode(res.body)
        end
      end
    end
  end
end
