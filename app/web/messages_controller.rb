class MessagesController < ApplicationController
  protect_from_forgery(
    except: [:messages]
  )

  # -- actions --
  def front
    if not is_signed?
      render(json: "", status: :unauthorized)
      return
    end

    upload_documents = Document::UploadFromMessage.new(
      decode_message: Front::DecodeMessage.new
    )

    upload_documents.(request.raw_post).each do |d|
      Documents::SyncFrontAttachmentWorker.perform_async(d.id)
    end
  end

  # -- queries --
  private def is_signed?
    algorithm = "sha1"

    signature = request.headers["X-Front-Signature"]
    evaluated = Base64.strict_encode64(OpenSSL::HMAC.digest(
      algorithm,
      ENV["FRONT_API_SECRET"],
      request.raw_post
    ))

    signature == evaluated
  end
end
