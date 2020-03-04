class MessagesController < ApplicationController
  protect_from_forgery(
    except: [:messages]
  )

  # -- actions --
  def front
    if not is_signed?
      return render(json: "", status: :unauthorized)
    end

    message = Front::DecodeMessage.new.(request.raw_post)
    Cases::AddMmsMessage.new.(message)
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

    return signature == evaluated
  end
end
