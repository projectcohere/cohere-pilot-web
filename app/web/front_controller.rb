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

    message_decode = Message::DecodeFrontJson.new
    message = message_decode.(request.raw_post)
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
