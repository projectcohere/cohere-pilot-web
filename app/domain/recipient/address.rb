module Recipient
  class Address < ::Value
    # -- props --
    prop(:street)
    prop(:street2, default: nil)
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

      lines.reject(&:blank?)
    end
  end
end
