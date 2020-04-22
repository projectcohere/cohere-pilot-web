class Program
  class Record < ApplicationRecord
    set_table_name!

    # -- associations --
    has_and_belongs_to_many(:partners, class_name: "Partner::Record", foreign_key: "program_id", association_foreign_key: "partner_id")
    has_many(:cases, class_name: "Case::Record", foreign_key: "program_id")

    # -- scopes --
    def self.with_no_case_for_recipient(recipient_id)
      query = <<~SQL
        SELECT 1
        FROM cases AS c
        WHERE c.program_id = programs.id AND c.recipient_id = ?
      SQL

      return where("NOT EXISTS (#{query})", recipient_id)
    end
  end
end
