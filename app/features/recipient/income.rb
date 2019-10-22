class Recipient
  class Income < ::Entity
    # -- props --
    prop(:month)
    prop(:amount)

    # -- lifetime --
    def initialize(month: nil, amount:)
      @month = month
      @amount = amount
    end
  end
end
