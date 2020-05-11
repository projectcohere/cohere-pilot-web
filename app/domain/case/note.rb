class Case
  class Note < ::Entity
    # -- props --
    prop(:id, default: Id::None)
    prop(:body)
    prop(:user_id)
  end
end
