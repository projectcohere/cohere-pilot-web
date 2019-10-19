class Recipient
  class Household < ::Entity
    # -- props --
    prop(:size)
    prop(:income_history)

    # -- lifetime --
    def initialize(size:, income_history:)
      @size = size
      @income_history = income_history
    end
  end
end
