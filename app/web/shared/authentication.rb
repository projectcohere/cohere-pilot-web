module Authentication
  extend ActiveSupport::Concern

  # -- hooks --
  included do
    # -- callbacks
    before_action(:build_user)
  end

  # -- commands --
  # builds a user entity from the current_user record fetched
  # by clearance
  def build_user
    if not current_user.nil?
      User::Repo.get.current = User::Repo.map_record(current_user)
    end
  end
end
