class User < ::Entity
  # TODO: should these be generalized for entity/ar?
  prop(:record, default: nil)
  prop(:events, default: ArrayQueue::Empty)

  # -- props --
  prop(:id, default: Id::None)
  prop(:email)
  prop(:role)
  prop(:confirmation_token, default: nil)

  # -- lifetime --
  def self.invite(invitation)
    user = User.new(email: invitation.email, role: invitation.role)
    user.events.add(Events::DidInvite.from_user(user))
    return user
  end

  # -- commands --
  def forget_password(confirmation_token)
    @confirmation_token = confirmation_token
  end

  # -- queries --
  def role_name
    @role.name
  end

  def organization_id
    @role.organization_id
  end

  # -- events --
  def did_save(record)
    @id.set(record.id)
    @record = record
  end
end
