class User
  class Repo < ::Repo
    include Service::Single

    # -- lifetime --
    def initialize(domain_events: ::Events::DispatchAll.get.events)
      @domain_events = domain_events
    end

    # -- queries --
    # -- queries/one
    def find_current
      @current
    end

    def find(id)
      record = User::Record
        .find(id)

      entity_from(record)
    end

    def find_by_remember_token(remember_token)
      user_rec = User::Record
        .find_by(remember_token: remember_token)

      entity_from(user_rec)
    end

    # -- commands --
    def sign_in(user_rec)
      if @current&.id&.val != user_rec&.id
        @current = user_rec != nil ? entity_from(user_rec) : nil
      end
    end

    def save_invited(user)
      user_rec = User::Record.new

      # update record
      u = user
      user_rec.assign_attributes(
        email: u.email,
        role: u.role.index,
        password: SecureRandom.uuid
      )

      p = u.partner
      user_rec.assign_attributes(
        partner_id: p.id,
      )

      # save record
      user_rec.save!
      user_rec.forgot_password!
      user.forget_password(user_rec.confirmation_token)

      # send creation events back to entities
      user.did_save(user_rec)

      # consume all entity events
      @domain_events.consume(user.events)
    end

    # -- factories --
    def self.map_record(r)
      return User.new(
        id: Id.new(r.id),
        email: r.email,
        role: Role.from_key(r.role),
        admin: r.admin,
        partner: Partner::Repo.map_record(r.partner),
        confirmation_token: r.confirmation_token
      )
    end
  end
end
