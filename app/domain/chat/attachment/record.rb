class Chat
  class Attachment
    class Record < ApplicationRecord
      # -- associations --
      belongs_to(:message, child: true)
      belongs_to(:file, class_name: "::ActiveStorage::Blob", optional: true)
    end
  end
end
