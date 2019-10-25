class Recipient
  class Account < Entity
    # -- props --
    prop(:supplier)
    prop(:number)
    prop(:arrears)

    # -- liftime --
    def initialize(supplier:, number:, arrears:)
      @supplier = supplier
      @number = number
      @arrears = arrears
    end
  end
end
