class Money
  # -- props --
  attr(:cents)

  # -- lifetime --
  def initialize(cents)
    @cents = cents
  end

  # -- queries --
  def dollars
    if @cents == nil
      return nil
    end

    return "#{cents / 100}.#{cents % 100}"
  end

  # -- factories --
  def self.cents(cents)
    return Money.new(cents)
  end

  def self.dollars(dollars)
    if dollars == nil
      return nil
    end

    return Money.cents(dollars.tr(".", "").to_i)
  end
end
