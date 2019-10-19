class Recipient
  class Record < ::ApplicationRecord
    # TODO: generalize this for feature-namespaced records?
    self.table_name = :recipients

    # -- associations --
    has_many(:cases, foreign_key: "recipient_id", class_name: "::Case::Record")
    has_one(:account, foreign_key: "recipient_id", class_name: "::Recipient::Account::Record")
    has_one(:household, foreign_key: "recipient_id", class_name: "::Recipient::Household::Record")
  end
end
