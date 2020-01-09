class Chat
  class Message
    class Record < ApplicationRecord
      set_table_name!

      # -- associations --
      belongs_to(:chat, class_name: "::Chat::Record")
    end
  end
end
