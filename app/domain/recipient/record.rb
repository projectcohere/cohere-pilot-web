module Recipient
  class Record < ::ApplicationRecord
    set_table_name!

    # -- associations --
    has_many(:cases, foreign_key: "recipient_id", class_name: "::Case::Record", dependent: :destroy)
    has_one(:chat, foreign_key: "recipient_id", class_name: "::Chat::Record", dependent: :destroy)

    # -- household ownership --
    enum(household_ownership: Ownership.all)
  end
end
