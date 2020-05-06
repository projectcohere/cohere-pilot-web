module Twilio
  class DeleteMedia < ::Command
    # -- lifetime --
    def initialize(client: Twilio::Client.get)
      @client = client
    end

    # -- command --
    def call(media_url)
      assert(media_url != nil, "media_url must not be nil!")
      res = @client.delete("#{media_url}.json")

      # TODO: we should reserve assert for developer errors and create
      # different error types / helpers for behavioral errors.
      assert(res.success?, "failed to delete media (#{res.status}): #{media_url}")
    end
  end
end
