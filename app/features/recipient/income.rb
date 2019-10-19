class Recipient
  class Income < ::Entity
    # -- props --
    prop(:month)
    prop(:amount)

    # -- lifetime --
    def initialize(month:, amount:)
      @month = month
      @amount = amount
    end
  end
end
