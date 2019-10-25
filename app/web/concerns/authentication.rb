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
    case case_policy.scope_for_user
    when :inbound
      cases_inbound_index_path
    when :opened
      cases_opened_index_path
    when :submitted
      cases_submitted_index_path
    when :root
      cases_path
    end
  end
end
