class SessionsController < Clearance::SessionsController;
  include Authentication

  protected

  def url_after_create
    policy = Case::Policy.new(build_user)

    if policy.permit?(:list)
      cases_path
    else
      inbound_cases_path
    end
  end
end
