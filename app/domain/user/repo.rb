class User
  class Repo < ::Repo
    # -- lifetime --
    def self.get
      Services.user_repo ||= Repo.new
    end

    def initialize(domain_events: Services.domain_events)
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
    def find_all_for_opened_case
      user_recs = User::Record
        .by_membership(Partner::Membership::Cohere, Partner::Membership::Governor)

      user_recs.map { |r| entity_from(r) }
    end

    def find_all_for_submitted_case(kase)
      user_recs = User::Record
        .where(partner_id: kase.enroller_id)

      user_recs.map { |r| entity_from(r) }
    end

    def find_all_for_completed_case
      user_recs = User::Record
        .by_membership(Partner::Membership::Cohere)

      user_recs.map { |r| entity_from(r) }
    end

    # -- commands --
    def current=(user)
      @current = user
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
      return Role.new(
        name: r.partner.membership&.to_sym,
        partner_id: r.partner.id,
      )
    end
  end

  class Record
    # -- scopes --
    def self.by_membership(*membership)
      scope = self
        .includes(:partner)
        .references(:partners)
        .where(partners: { membership: membership })

      return scope
    end
  end
end
