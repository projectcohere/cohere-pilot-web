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

    # -- queries/many
    def find_all_for_opened_case
      records = User::Record
        .where(organization_type: [:cohere, :dhs])

      entities_from(records)
    end

    def find_all_for_submitted_case(kase)
      records = User::Record
        .where(
          organization_type: Enroller::Record.name,
          organization_id: kase.enroller_id
        )

      entities_from(records)
    end

    def find_all_for_completed_case
      records = User::Record
        .where(organization_type: :cohere)

      entities_from(records)
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
      organization_type = case r.name
      when :cohere, :dhs
        r.name.to_s
      when :supplier
        Supplier::Record.name
      when :enroller
        Enroller::Record.name
      end

      user_rec.assign_attributes(
        organization_type: organization_type,
        organization_id: r.organization_id
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
      # create entity
      User.new(
        id: Id.new(r.id),
        email: r.email,
        role: map_role(r),
        confirmation_token: r.confirmation_token
      )
    end

    def self.map_role(r)
      # parse role from org type. if the user has an org with
      # an associated record it will be the record's class name.
      role = case r.organization_type
      when "cohere"
        Role.new(name: :cohere)
      when "dhs"
        Role.new(name: :dhs)
      when Enroller::Record.to_s
        Role.new(name: :enroller, organization_id: r.organization_id)
      when Supplier::Record.to_s
        Role.new(name: :supplier, organization_id: r.organization_id)
      end
    end
  end
end
