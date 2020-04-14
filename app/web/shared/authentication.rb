module Authentication
  extend ActiveSupport::Concern

  # -- hooks --
  included do
    # -- callbacks
    before_action(:remember_user)
  end

  # Clearance::Authentication
  def sign_in(user_rec)
    super(user_rec)

    sign_in_as(user_rec)
    create_chat_user_id
  end

  def sign_out
    destroy_chat_user_id
    super
  end

  # -- commands --
  # builds a user entity from the current_user record fetched
  # by clearance
  def remember_user
    if current_user != nil
      sign_in_as(current_user)
    end
  end

  # store chat id used to disambiguate concurrent cohere users
  def create_chat_user_id
    user = User::Repo.get.find_current

    # TODO: scope by policy
    if user&.role&.membership&.cohere?
      cookies.signed[:chat_user_id] = SecureRandom.base58
    end
  end

  # destroy chat id used to disambiguate concurrent cohere users
  def destroy_chat_user_id
    cookies.delete(:chat_user_id)
  end

  # -- commands/helpers
  private def sign_in_as(user_rec)
    User::Repo.get.current = user_rec == nil ? nil : User::Repo.map_record(user_rec)
  end
end
