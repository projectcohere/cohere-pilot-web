module Agent
  class AdminController < ApplicationController
    # -- actions --
    def hours
      settings.working_hours = params[:status] == "on"
      redirect_to(admin_path)
    end
  end
end
