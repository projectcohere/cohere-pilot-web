class Chat
  class Record < ApplicationRecord
    # -- associations --
    has_many(:messages, child: true, dependent: :destroy)
    belongs_to(:recipient)
  end
end
