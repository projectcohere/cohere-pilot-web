class Case
  class Record < ::ApplicationRecord
    set_table_name!

    # -- associations --
    belongs_to(:recipient, class_name: "::Recipient::Record")
    belongs_to(:enroller, class_name: "::Enroller::Record")
    belongs_to(:supplier, class_name: "::Supplier::Record")
    belongs_to(:referrer, class_name: "::Supplier::Record", optional: true)
    has_many(:documents, foreign_key: "case_id", class_name: "::Document::Record")

    # -- program --
    enum(program: Program::Name.all)

    # -- status --
    enum(status: Status.all)
  end
end
