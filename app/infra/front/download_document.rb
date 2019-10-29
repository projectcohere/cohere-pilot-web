module Front
  class DownloadDocument
    def call(document_url)
      uri = URI.parse(document_url)
      Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        res = http.get(uri, { "Authorization" => "Bearer #{ENV["FRONT_API_JWT"]}" })
        res.body
      end
    end
  end
end
