class Message
  class ReceiveFromRecipient
    attr_reader(:recipient)

    # -- lifetime --
    def initialize(decode:, recipients: Recipient::Repo.new)
      @decode = decode
      @recipients = recipients
    end

    # -- command --
    def call(data)
      message = @decode.(data)
      message_phone_number = message.sender.phone_number

      @recipient = @recipients.find_one_by_phone_number(message_phone_number)
      if @recipient.nil?
        raise "No recipient found for phone number #{message_phone_number}"
      end

      @recipient.add_documents_from_message(message)
      @recipients.save_new_documents(@recipient)
    end
  end
end
