class Case
  class Note
    class Record < ApplicationRecord
      # -- associations --
      belongs_to(:case)
      belongs_to(:user)

      # -- scopes --
      def self.by_most_recent
        return order(created_at: :desc)
      end
    end
  end
end
