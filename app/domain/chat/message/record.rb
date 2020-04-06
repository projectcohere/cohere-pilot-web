class Chat
  class Message
    class Record < ApplicationRecord
      set_table_name!

      # -- associations --
      belongs_to(:chat, class_name: "::Chat::Record")
      has_many(:attachments, dependent: :destroy, foreign_key: "message_id", class_name: "::Chat::Attachment::Record")

      # -- status --
      enum(status: Status.keys)
    end
  end
end
