class Recipient
  class Household
    module Ownership
      # -- options --
      Unknown = :unknown
      Rent = :rent
      Own = :own

      # -- queries --
      def self.all
        @all ||= [
          Unknown,
          Rent,
          Own
        ]
      end
    end
  end
end
