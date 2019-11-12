module Users
  class PasswordsController < Clearance::PasswordsController
    # clearance doesn't respect standard pathing
    prepend_view_path("app/views/users")

    # -- actions --
    def edit
      # expose invited state to view
      @invited = session[:password_reset_invited] || false

      super

      # store invited state in the session to preserve through redirect
      if response.redirect? && params[:invited]
        session[:password_reset_invited] = params[:invited]
      end
    end
  end
end
