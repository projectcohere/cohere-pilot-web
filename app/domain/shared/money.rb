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

    return "#{cents / 100}.#{(cents % 100).to_s.ljust(2, "0")}"
  end

  # -- factories --
  def self.cents(cents)
    if cents == nil
      return nil
    end

   return Money.new(cents)
  end

  def self.dollars(dollars)
    if dollars.blank?
      return nil
    end

    whole, fraction = dollars.split(".")

    cents = whole.to_i * 100
    cents += case fraction&.length
    when nil
      0
    when 1
      fraction.to_i * 10
    else
      fraction[0, 2].to_i
    end

    return self.cents(cents)
  end
end
