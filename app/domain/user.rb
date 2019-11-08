class User < ::Entity
  # TODO: should these be generalized for entity/ar?
  prop(:record, default: nil)
  prop(:events, default: EventQueue::Empty)

  # -- props --
  prop(:id, default: Id::None)
  prop(:email)
  prop(:role)
  props_end!

  # -- lifetime --
  def self.invite(email, role:)
    user = User.new(email: email, role: role)
    user.events << Events::DidInvite.from_user(user)
    user
  end

  # -- queries --
  def role_name
    role.name
  end

  # -- events --
  def did_save(record)
    @id.set(record.id)
    @record = record
  end
end
