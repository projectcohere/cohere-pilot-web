class TestsController < ApplicationController
  def chat_session
    cookies.encrypted.signed[:chat_session_token] = params[:token]
  end
end
