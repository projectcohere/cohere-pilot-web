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

    user_repo.sign_in(current_user)
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
      user_repo.sign_in(current_user)
    end
  end

  # store chat id used to disambiguate concurrent cohere users
  def create_chat_user_id
    # TODO: scope by policy
    if user&.role&.membership&.cohere?
      cookies.signed[:chat_user_id] = SecureRandom.base58
    end
  end

  # destroy chat id used to disambiguate concurrent cohere users
  def destroy_chat_user_id
    cookies.delete(:chat_user_id)
  end

  # -- queries --
  private def user_repo
    return User::Repo.get
  end
end
