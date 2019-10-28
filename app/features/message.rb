class Message < ::Entity
  # -- props --
  prop(:recipient)

  # -- liftime --
  def initialize(recipient:)
    @recipient = recipient
  end

  # -- children --
  class Recipient < :: Entity
    # -- props --
    prop(:phone_number)

    # -- lifetime --
    def initialize(phone_number:)
      @phone_number = phone_number
    end
  end
end
