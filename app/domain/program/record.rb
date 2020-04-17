class Program
  class Record < ApplicationRecord
    set_table_name!

    # -- associations --
    has_and_belongs_to_many(:partners, class_name: "Partner::Record", foreign_key: "program_id", association_foreign_key: "partner_id")
  end
end
