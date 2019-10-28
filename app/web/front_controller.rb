class FrontController < ApplicationController
  protect_from_forgery(
    except: [:messages]
  )

  def messages
    if not is_signed?
      render(json: "", status: :unauthorized)
      return
    end
  end

  private

  def is_signed?
    algorithm = "sha1"

    signature = request.headers["X-Front-Signature"]
    evaluated = Base64.strict_encode64(OpenSSL::HMAC.digest(
      algorithm,
      ENV["FRONT_API_SECRET"],
      request.raw_post
    ))
    binding.pry

    signature == evaluated
  end
end
