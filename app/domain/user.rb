class User < ::Entity
  prop(:record, default: nil)
  prop(:events, default: ListQueue::Empty)

  # -- props --
  prop(:id, default: Id::None)
  prop(:email)
  prop(:role)
  prop(:admin, predicate: true)
  prop(:partner)
  prop(:confirmation_token, default: nil)

  # -- lifetime --
  def self.invite(invitation)
    user = User.new(
      email: invitation.email,
      role: invitation.role,
      admin: false,
      partner: Partner.new(
        id: invitation.partner_id,
        name: nil,
        membership: nil,
        programs: nil,
      ),
    )

    user.events.add(Events::DidInvite.from_user(user))
    return user
  end

  # -- commands --
  def forget_password(confirmation_token)
    @confirmation_token = confirmation_token
  end

  # -- queries --
  def membership
    return @partner.membership
  end

  def partner_id
    return @partner.id
  end

  # -- events --
  def did_save(record)
    @id.set(record.id)
    @record = record
  end
end
