module Cases
  module Views
    # A Case read model for rendering barebones case detail.
    class Reference < Read
      include Routing

      # -- props --
      prop(:id)
      prop(:recipient_id)
      prop(:recipient_name)

      # -- lifetime --
      def initialize(chat_repo: Chat::Repo.get, **props)
        @chat_repo = chat_repo
        super(props)
      end

      # -- queries --
      def recipient_first_name
        return @recipient_name.first
      end

      # -- queries/chat
      def chat
        # TODO: return Chats::Views::Detail instead of entity
        return @chat ||= @chat_repo.find_by_recipient_with_messages(recipient_id)
      end
    end
  end
end
