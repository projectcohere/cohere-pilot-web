module Twilio
  class DownloadMedia < ::Command
    # -- lifetime --
    def initialize(client: Twilio::Client.get)
      @client = client
    end

    # -- command --
    def call(source_url)
      assert(source_url != nil, "source_url must not be nil!")

      res = @client.get(source_url)
      if not res.success?
        return nil
      end

      return FileData.new(
        data: StringIO.new(res.body),
        name: res.filename,
        mime_type: res.content_type
      )
    end
  end
end
