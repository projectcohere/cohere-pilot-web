require "open-uri"

module Twilio
  class DownloadMedia < ::Command
    # -- lifetime --
    def initialize(client: Twilio::Client.get)
      @client = client
    end

    # -- command --
    def call(kase)
      document = kase.selected_document
      if document.nil?
        raise "can't download media without a selected document"
      end

      source_url = document.source_url
      if source_url.nil?
        raise "can't download media without source url: #{document}"
      end

      res = @client.get(source_url)

      return FileData.new(
        data: StringIO.new(res.body),
        name: res.filename,
        mime_type: res.content_type
      )
    end
  end
end
