module Recipient
  class Ownership < ::Option
    # -- options --
    option(:unknown)
    option(:rent)
    option(:own)

    # -- statics --
    def self.valid
      return [Rent, Own]
    end
  end
end
