class Recipient
  class Address < ::Value
    # -- props --
    prop(:street)
    prop(:street2)
    prop(:city)
    prop(:state)
    prop(:zip)
    props_end!

    # -- queries --
    def to_lines
      lines = [
        "#{@street}",
        "#{@street2}",
        "#{@city}, #{@state} #{@zip}"
      ]

      lines.select(&:present?)
    end
  end
end
