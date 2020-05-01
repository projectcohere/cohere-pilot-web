class Case
  class Record < ApplicationRecord
    # -- associations --
    belongs_to(:program)
    belongs_to(:recipient)
    belongs_to(:enroller, record: :partner)
    belongs_to(:supplier, record: :partner, optional: true)

    # -- associations/children
    has_many(:documents, dependent: :destroy)
    has_many(:assignments, child: true, dependent: :destroy)

    # -- associations/referrals
    has_one(:referred, record: :case, foreign_key: "referrer_id")
    belongs_to(:referrer, record: :case, optional: true)

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

    def self.join_assignments
      return includes(:assignments)
    end

    def self.incomplete
      return where(completed_at: nil)
    end

    def self.complete
      return where.not(completed_at: nil)
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
          status: [Status::Opened, Status::Pending],
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
        status: [Status::Submitted, Status::Approved, Status::Denied],
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

    def self.by_updated_date
      return order(updated_at: :desc)
    end

    def self.by_completed_date
      return order(completed_at: :desc)
    end
  end
end
