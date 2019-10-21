module Authentication
  extend ActiveSupport::Concern

  included do
    before_action(:build_user)
  end

  # builds a user entity from the current_user record fetched
  # by clearance
  def build_user
    if not current_user.nil?
      Current.user = User::from_record(current_user)
    end
  end

  # determines the root path based on the authenticatd user's
  # permissions
  def root_path_by_permissions
    case_policy = Case::Policy.new(Current.user)

    if case_policy.permit?(:list)
      cases_path
    else
      inbound_cases_path
    end
  end
end
