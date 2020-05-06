module Cases
  module Views
    class ProgramPicker < ::Value
      include Routing

      # -- fields --
      prop(:id, default: Id::None)
      prop(:recipient_id)
      prop(:recipient_name)
      prop(:programs)

      # -- lifetime --
      def initialize(chat_repo: Chat::Repo.get, **props)
        @chat_repo = chat_repo
        super(props)
      end

      # -- queries --
      def program_options
        return @programs.map do |p|
          [p.name, p.id]
        end
      end

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
