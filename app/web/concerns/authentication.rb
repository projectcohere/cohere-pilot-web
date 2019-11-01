module Authentication
  extend ActiveSupport::Concern

  # -- hooks --
  included do
    # -- helpers
    helper_method(:case_scope)
    # -- callbacks
    before_action(:build_user)
  end

  # -- commands --
  # builds a user entity from the current_user record fetched
  # by clearance
  def build_user
    if not current_user.nil?
      Current.user = User::from_record(current_user)
    end
  end

  # -- queries --
  def case_scope
    @case_scope ||= CaseScope.new(:root, Current.user)
  end
end
