class Chat
  class Record < ::ApplicationRecord
    set_table_name!

    # -- associations --
    has_many(:messages, foreign_key: "chat_id", class_name: "::Chat::Message::Record", dependent: :destroy)
    belongs_to(:recipient, class_name: "::Recipient::Record")
  end
end
