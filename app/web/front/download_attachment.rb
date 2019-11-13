require "open-uri"

module Front
  class DownloadAttachment
    def call(kase)
      document = kase.selected_document
      if document.nil?
        raise "can't download attachment without a selected document"
      end

      source_url = document.source_url
      if source_url.nil?
        raise "can't download attachment without source url: #{document}"
      end

      response = open(source_url,
        "Authorization" => "Bearer #{ENV["FRONT_API_JWT"]}"
      )

      FileData.new(
        data: response,
        name: ->(r) { r.meta["content-disposition"][/filename="([^"]+)"/, 1] },
        mime_type: response.content_type
      )
    end
  end
end
