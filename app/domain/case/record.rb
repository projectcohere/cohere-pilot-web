class Case
  class Record < ApplicationRecord
    # -- associations --
    belongs_to(:program)
    belongs_to(:recipient)
    belongs_to(:enroller, record: :partner)
    belongs_to(:supplier, record: :partner, optional: true)

    # -- associations/children
    has_many(:assignments, child: true, dependent: :destroy)
    has_many(:notes, child: true, dependent: :destroy)
    has_many(:documents, dependent: :destroy)

    # -- status --
    enum(status: Status.keys, condition: Condition.keys)

    # -- scopes --
    def self.visible
      return where.not(condition: Condition::Deleted.key)
    end

    def self.join_recipient(references: false)
      scope = includes(:recipient)
      if references
        scope = scope.references(:recipients)
      end
      return scope
    end

    def self.join_supplier
      return includes(:supplier)
    end

    def self.join_assignments
      return includes(:assignments)
    end

    def self.with_recipient_name(name)
      name_col = <<-SQL.strip
        (recipients.first_name || ' ' || recipients.last_name)
      SQL

      scope = self
        .join_recipient(references: true)
        .select("set_limit(0.4)")
        .where("#{name_col} % ?", name)
        .order(Arel.sql("similarity(#{name_col}, #{connection.quote(name)}) DESC"))

      return scope
    end

    def self.with_phone_number(phone_number)
      scope = self
        .join_recipient
        .where(recipients: { phone_number: phone_number })

      return scope
    end

    def self.for_role(role, partner_id)
      return case role
      when Role::Source
        for_source(partner_id)
      when Role::Governor
        for_governor(partner_id)
      when Role::Enroller
        for_enroller(partner_id)
      else
        all
      end
    end

    def self.for_source(partner_id)
      scope = self
        .includes(:assignments)
        .references(:case_assignments)
        .where(
          case_assignments: {
            partner_id: partner_id
          }
        )

      return scope
    end

    def self.for_governor(partner_id)
      scope = self
        .includes(program: :partners)
        .where(
          status: [Status::Opened.key],
          programs: {
            partners_programs: {
              partner_id: partner_id,
            },
          },
        )

      return scope
    end

    def self.for_enroller(enroller_id)
      return where(
        enroller_id: enroller_id,
        status: [Status::Submitted.key, Status::Approved.key, Status::Denied.key],
      )
    end

    def self.with_assigned_user(user_id)
      scope = self
        .includes(:assignments)
        .references(:case_assignments)
        .where(
          case_assignments: {
            user_id: user_id
          }
        )

      return scope
    end

    def self.with_no_assignment_for_role(role)
      query = <<~SQL
        SELECT 1
        FROM case_assignments AS ca
        WHERE ca.case_id = cases.id AND ca.role = ?
      SQL

      return where("NOT EXISTS (#{query})", role.to_i)
    end

    def self.with_completion_between(start_date, end_date)
      return where(
        completed_at: start_date.beginning_of_day..end_date.end_of_day,
      )
    end

    def self.by_updated_date
      return order(updated_at: :desc)
    end

    def self.by_completed_date
      return order(completed_at: :desc)
    end
  end
end
