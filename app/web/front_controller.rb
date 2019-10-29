class FrontController < ApplicationController
  protect_from_forgery(
    except: [:messages]
  )

  # -- actions --
  def messages
    if not is_signed?
      render(json: "", status: :unauthorized)
      return
    end

    receive_message = Message::ReceiveFromRecipient.new(
      decode: Message::DecodeFrontJson.new
    )

    receive_message.(request.raw_post)
    receive_message.recipient.documents.each do |d|
      if d.url.nil?
        # TODO: filter out documents that already have scheduled jobs?
        Front::SyncDocumentWorker.perform_async(d.id)
      end
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
