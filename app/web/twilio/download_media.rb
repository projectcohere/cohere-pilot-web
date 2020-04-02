require "open-uri"

module Twilio
  class DownloadMedia < ::Command
    # -- lifetime --
    def self.get
      return DownloadMedia.new
    end

    def initialize(client: Twilio::Client.get)
      @client = client
    end

    # -- command --
    def call(source_url)
      assert(source_url != nil, "source_url must not be nil!")

      res = @client.get(source_url)

      return FileData.new(
        data: StringIO.new(res.body),
        name: res.filename,
        mime_type: res.content_type
      )
    end
  end
end
