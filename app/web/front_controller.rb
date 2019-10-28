class FrontController < ApplicationController
  protect_from_forgery(except: [:messages])

  def messages
    request.headers.each do |(key, value)|
      logger.debug("#{key}=#{value}")
    end
  end
end
