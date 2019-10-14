module Authentication
  extend ActiveSupport::Concern

  included do
    before_action(:build_user)
  end

  # builds a user entity from the current_user record fetched
  # by clearance
  def build_user
    if current_user != nil
      Current.user = User::from_record(current_user)
    end
  end
end
