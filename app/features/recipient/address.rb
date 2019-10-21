class Recipient
  class Address
    # -- lifetime --
    def initialize(street:, street2:, city:, state:, zip:)
      @street = street
      @street2 = street2
      @city = city
      @state = state
      @zip = zip
    end

    # -- queries --
    def to_lines
      [
        "#{@street}",
        "#{@street2}",
        "#{@city}, #{@state} #{@zip}"
      ]
    end
  end
end
