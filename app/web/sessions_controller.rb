class SessionsController < Clearance::SessionsController;
  protected

  def url_after_create
    cases_path
  end
end
