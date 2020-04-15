class Money
  # -- props --
  attr(:cents)

  # -- lifetime --
  def initialize(cents)
    @cents = cents
  end

  # -- queries --
  def dollars
    return cents != nil ? cents / 100.0 : nil
  end

  # -- factories
  def self.cents(cents)
    return Money.new  (cents)
  end

  def self.dollars(dollars)
    return Money.cents((dollars.to_f * 100.0).to_i)
  end
end
