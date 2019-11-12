require "open-uri"

module Front
  class DownloadAttachment
    def call(document_url)
      response = open(document_url,
        "Authorization" => "Bearer #{ENV["FRONT_API_JWT"]}"
      )

      Documents::File.new(
        data: response,
        name: ->(r) { r.meta["content-disposition"][/filename="([^"]+)"/, 1] },
        mime_type: response.content_type
      )
    end
  end
end
