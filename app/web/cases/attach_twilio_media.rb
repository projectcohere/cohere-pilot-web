module Cases
  class AttachTwilioMedia < ApplicationWorker
    # -- command --
    def call(case_id, document_id)
      attach_file = AttachFile.new(generate: Twilio::DownloadMedia.new)
      attach_file.(case_id, document_id)
    end

    alias :perform :call
  end
end
