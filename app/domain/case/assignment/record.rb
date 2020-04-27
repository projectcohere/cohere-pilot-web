class Case
  class Assignment
    class Record < ApplicationRecord
      # -- associations --
      belongs_to(:case)
      belongs_to(:user)
      belongs_to(:partner)

      # -- roles --
      enum(role: Role.keys)

      # -- scopes --
      def self.join_user
        return includes(:user)
      end

      def self.by_partner(partner_id)
        return where(partner_id: partner_id)
      end
    end
  end
end
