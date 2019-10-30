class Recipient
  class Record < ::ApplicationRecord
    # TODO: generalize this for feature-namespaced records?
    self.table_name = :recipients

    # -- callbacks --
    before_validation(:normalize_phone_number)

    # -- associations --
    has_many(:cases, foreign_key: "recipient_id", class_name: "::Case::Record")
    has_one(:account, foreign_key: "recipient_id", class_name: "::Recipient::Account::Record")
    has_one(:household, foreign_key: "recipient_id", class_name: "::Recipient::Household::Record")
    has_many(:documents, foreign_key: "recipient_id", class_name: "::Recipient::Document::Record")

    # -- commands --
    # this should be enforced elsewhere -- on set in the domain model
    private def normalize_phone_number
      self.phone_number = begin
        normalized = phone_number.gsub(/\D/, "")
        normalized = "1#{normalized}" if not normalized.starts_with?("1")
        normalized = "+#{normalized}"
        normalized
      end
    end
  end
end
