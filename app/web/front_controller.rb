class FrontController < ApplicationController
  protect_from_forgery(except: [:messages])

  def messages
    logger.debug("POST /front/messages")

    logger.debug("headers\n-------")
    request.headers.each do |(key, value)|
      logger.debug("#{key}=#{value}")
    end

    logger.debug("body\n----")
    logger.debug(request.raw_post)
  end
end
