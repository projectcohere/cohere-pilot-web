class Chat
  class Message
    class Record < ApplicationRecord
      # -- associations --
      belongs_to(:chat)
      has_many(:attachments, child: true, dependent: :destroy)

      # -- status --
      enum(status: Status.keys)
    end
  end
end
