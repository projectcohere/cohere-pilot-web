module Agent
  class AdminController < ApplicationController
    include Policy::Context::Shared

    # -- helpers --
    helper_method(:settings)

    # -- actions --
    def hours
      settings.working_hours = params[:status] == "on"
      redirect_to(admin_path)
    end

    # -- queries --
    private def settings
      return Settings.get
    end
  end
end
