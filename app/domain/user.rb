class User < ::Entity
  # TODO: should these be generalized for entity/ar?
  prop(:record, default: nil)
  prop(:events, default: EventQueue::Empty)

  # -- props --
  prop(:id, default: Id::None)
  prop(:email)
  prop(:role)
  prop(:confirmation_token, default: nil)
  props_end!

  # -- lifetime --
  def self.invite(invitation)
    user = User.new(email: invitation.email, role: invitation.role)
    user.events << Events::DidInvite.from_user(user)
    user
  end

  # -- commands --
  def forget_password(confirmation_token)
    @confirmation_token = confirmation_token
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
