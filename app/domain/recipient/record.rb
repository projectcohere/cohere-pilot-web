module Recipient
  class Record < ::ApplicationRecord
    set_table_name!

    # -- associations --
    has_many(:cases, foreign_key: "recipient_id", class_name: "::Case::Record")
    has_one(:chat, foreign_key: "recipient_id", class_name: "::Chat::Record")

    # -- household ownership --
    enum(household_ownership: Household::Ownership.all)
  end
end
