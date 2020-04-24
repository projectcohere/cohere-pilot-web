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

    # -- queries/many
    def find_emails_for_opened_case
      user_query = User::Record
        .by_membership(Partner::Membership::Cohere, Partner::Membership::Governor)

      return user_query.pluck(:email)
    end

    def find_emails_for_submitted_case(kase)
      user_query = User::Record
        .where(partner_id: kase.enroller_id)

      return user_query.pluck(:email)
    end

    def find_emails_for_completed_case
      user_query = User::Record
        .by_membership(Partner::Membership::Cohere)

      return user_query.pluck(:email)
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
      user_rec.assign_attributes(
        email: user.email,
        password: SecureRandom.uuid
      )

      r = user.role
      user_rec.assign_attributes(
        partner_id: r.partner_id,
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
        role: map_role(r),
        confirmation_token: r.confirmation_token
      )
    end

    def self.map_role(r)
      return User::Role.new(
        partner_id: r.partner.id,
        membership: Partner::Membership.from_key(r.partner.membership),
      )
    end
  end

  class Record
    # -- scopes --
    def self.by_membership(*membership)
      scope = self
        .includes(:partner)
        .where(partners: { membership: membership.map(&:key) })

      return scope
    end
  end
end
