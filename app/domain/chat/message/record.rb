class Chat
  class Message
    class Record < ApplicationRecord
      set_table_name!

      # -- associations --
      belongs_to(:chat, class_name: "::Chat::Record")
      has_many_attached(:files)
    end
  end
end
