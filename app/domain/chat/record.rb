class Chat
  class Record < ::ApplicationRecord
    set_table_name!

    # -- associations --
    has_many(:messages, foreign_key: "chat_id", class_name: "::Chat::Message::Record")
    belongs_to(:recipient, class_name: "::Recipient::Record")

    # -- notification --
    enum(notification: %i[
      clear
      reminder_1
    ])
  end
end
