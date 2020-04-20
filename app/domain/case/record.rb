class Case
  class Record < ::ApplicationRecord
    set_table_name!

    # -- associations --
    belongs_to(:program, class_name: "::Program::Record")
    belongs_to(:recipient, class_name: "::Recipient::Record")
    belongs_to(:enroller, class_name: "::Partner::Record")
    belongs_to(:supplier, class_name: "::Partner::Record")

    # -- associations/children
    has_many(:documents, foreign_key: "case_id", class_name: "::Document::Record", dependent: :destroy)
    has_many(:assignments, foreign_key: "case_id", class_name: "::Case::Assignment::Record", dependent: :destroy)

    # -- associations/referrals
    has_one(:referred, class_name: "::Case::Record", foreign_key: "referrer_id")
    belongs_to(:referrer, class_name: "::Case::Record", optional: true)

    # -- status --
    enum(status: Status.all)

    # -- scopes --
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

    def self.for_supplier(supplier_id)
      return where(
        supplier_id: supplier_id
      )
    end

    def self.for_governor(governor_id)
      scope = self
        .includes(program: :partners)
        .where(
          status: [Status::Opened, Status::Pending],
          programs: {
            partners_programs: {
              partner_id: governor_id,
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
        .where(case_assignments: { user_id: user_id })

      return scope
    end

    def self.with_no_assignment_for_partner(partner_id)
      query = <<~SQL
        SELECT 1
        FROM case_assignments AS ca
        WHERE ca.case_id = cases.id AND ca.partner_id = ?
      SQL

      return where("NOT EXISTS (#{query})", partner_id)
    end

    def self.by_updated_date
      return order(updated_at: :desc)
    end

    def self.by_completed_date
      return order(completed_at: :desc)
    end
  end
end
