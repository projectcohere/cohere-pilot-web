module Chats
  class DeleteRemoteAttachment < ApplicationWorker
    # -- lifetime --
    def initialize(delete_media: Twilio::DeleteMedia.get)
      @delete_media = delete_media
    end

    # -- command --
    def call(attachment_url)
      @delete_media.(attachment_url)
    end
  end
end
