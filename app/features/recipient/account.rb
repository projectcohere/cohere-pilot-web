class Recipient
  class Account < Entity
    # -- props --
    prop(:number)
    prop(:arrears)

    # -- liftime --
    def initialize(number:, arrears:)
      @number = number
      @arrears = arrears
    end
  end
end
