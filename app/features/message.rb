class Message < ::Entity
  # -- props --
  prop(:sender)
  prop(:attachments)

  # -- liftime --
  def initialize(sender:, attachments:)
    @sender = sender
    @attachments = attachments
  end

  # -- children --
  class Sender < :: Entity
    # -- props --
    prop(:phone_number)

    # -- lifetime --
    def initialize(phone_number:)
      @phone_number = phone_number
    end
  end

  class Attachment < :: Entity
    # -- props --
    prop(:url)

    # -- lifetime --
    def initialize(url:)
      @url = url
    end
  end
end
