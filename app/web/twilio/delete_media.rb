module Twilio
  class DeleteMedia < ::Command
    # -- lifetime --
    def self.get
      return DeleteMedia.new
    end

    def initialize(client: Twilio::Client.get)
      @client = client
    end

    # -- command --
    def call(media_url)
      assert(media_url != nil, "media_url must not be nil!")
      res = @client.delete("#{media_url}.json")

      # TODO: we should reserve assert for developer errors and create
      # different error types / helpers for behavioral errors.
      assert(res.status == 204, "failed to delete media: #{media_url}")
    end
  end
end
