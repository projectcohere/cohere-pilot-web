module Reports
  class BaseController < ApplicationController
    def new
      @form = view_repo.new_form
    end

    # -- queries --
    private def view_repo
      return Reports::Views::Repo.get
    end
  end
end
