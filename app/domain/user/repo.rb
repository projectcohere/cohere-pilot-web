class User
  class Repo < ::Repo
    # -- lifetime --
    def self.get
      Repo.new
    end

    def initialize(event_queue: EventQueue.get)
      @event_queue = event_queue
    end

    # -- queries --
    # -- queries/one
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

    # -- commands --
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
      @event_queue.consume(user.events)
    end

    # -- factories --
    def self.map_record(r)
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

      # create entity
      User.new(
        id: r.id,
        email: r.email,
        role: role,
        confirmation_token: r.confirmation_token
      )
    end
  end
end
