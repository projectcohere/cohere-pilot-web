class Case
  class Note < ::Entity
    # -- props --
    prop(:id, default: Id::None)
    prop(:body)
    prop(:user_id)
    prop(:user_email)
    prop(:created_at, default: nil)
  end
end
