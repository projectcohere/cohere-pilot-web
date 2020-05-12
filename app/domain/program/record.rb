class Program
  class Record < ApplicationRecord
    # -- associations --
    has_many(:cases)
    has_and_belongs_to_many(:partners)

    # -- scopes --
    def self.active
      return where.not(priority: -1)
    end

    def self.for_partner(partner_id)
      query = self
        .includes(:partners)
        .where(partners: { id: partner_id })

      return query
    end

    def self.with_no_case_for_recipient(recipient_id)
      query = <<~SQL
        SELECT 1
        FROM cases AS c
        WHERE c.program_id = programs.id AND c.recipient_id = ?
      SQL

      scope = self
        .active
        .where("NOT EXISTS (#{query})", recipient_id)

      return scope
    end

    def self.by_priority
      return order(priority: :asc)
    end
  end
end
