module Reports
  class BaseController < ApplicationController
    def new
      @form = view_repo.new_form
    end

    def create
      @form = view_repo.new_form(params: params)
      if not @form.valid?
        flash.now[:alert] = t(".flashes.failure")
        return render(:new)
      end

      @report = view_repo.make_report(@form)
      send_data(
        @report.to_csv,
        type: :csv,
        filename: @report.filename,
      )
    end

    # -- queries --
    private def view_repo
      return Reports::Views::Repo.get
    end
  end
end
