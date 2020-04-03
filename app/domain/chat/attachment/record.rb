class Chat
  class Attachment
    class Record < ApplicationRecord
      set_table_name!

      # -- associations --
      belongs_to(:message, class_name: "::Chat::Message::Record")
      belongs_to(:file, class_name: "::ActiveStorage::Blob", optional: true)
    end
  end
end
