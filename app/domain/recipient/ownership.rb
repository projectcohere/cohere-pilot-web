module Recipient
  module Ownership
    # -- options --
    Unknown = :unknown
    Rent = :rent
    Own = :own

    # -- queries --
    class << self
      def keys
        @all ||= [
          Unknown,
          Rent,
          Own
        ]
      end

      alias :values :keys
    end
  end
end
