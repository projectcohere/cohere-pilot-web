class Address < ::Value
  # -- props --
  prop(:street)
  prop(:street2, default: nil)
  prop(:city)
  prop(:state)
  prop(:zip)

  # -- queries --
  def lines
    lines = [
      "#{@street}",
      "#{@street2}",
      "#{@city}, #{@state} #{@zip}"
    ]

    return lines.reject(&:blank?)
  end
end
