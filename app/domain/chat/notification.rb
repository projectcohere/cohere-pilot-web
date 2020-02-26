class Chat
  class Notification < ::Value
    prop(:recipient_name)
    prop(:is_new_conversation)

    # -- queries --
    def text
      lines = []

      if is_new_conversation
        lines << "Hi #{@recipient_name.first.titlecase}, this is Gaby from Cohere."
      end

      lines << case rand(3)
      when 0
        "You have some new messages"
      when 1
        "We sent you a few messages"
      when 2
        "There are a few messages for you"
      end

      lines << "on the Cohere web chat."

      lines << case rand(4)
      when 0
        "Here's the link:"
      when 1
        "If you need the link, it's"
      when 2
        "When you have a second, check them out here:"
      when 3
        "The link is"
      end

      lines << "https://projectcohere.com."

      return lines.join(" ")
    end
  end
end
