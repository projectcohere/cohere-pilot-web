module Chats
  class UploadRemoteAttachment < ApplicationWorker
    # -- lifetime --
    def initialize(
      download_media: Twilio::DownloadMedia.get,
      chat_repo: Chat::Repo.get
    )
      @download_media = download_media
      @chat_repo = chat_repo
    end

    # -- command --
    def call(attachment_id)
      chat = @chat_repo.find_by_attachment(attachment_id)
      file = @download_media.(chat.selected_attachment_url)
      chat.upload_selected_attachment(file)
      @chat_repo.save_uploaded_attachment(chat)
    end
  end
end
