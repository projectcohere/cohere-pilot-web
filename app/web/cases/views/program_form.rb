module Cases
  module Views
    class ProgramForm < ApplicationForm
      # -- fields --
      field(:program_id, :integer)

      # -- lifetime --
      def initialize(model, programs, attrs = {}, chat_repo: Chat::Repo.get)
        @programs = programs
        @chat_repo = chat_repo
        super(model, attrs)
      end

      # -- queries --
      def program_options
        return @programs.map { |p| [p.name, p.id] }
      end

      def recipient_first_name
        return @recipient_name.first
      end

      # -- queries/chat
      def chat
        # TODO: return Chats::Views::Detail instead of entity
        return @chat ||= @chat_repo.find_by_recipient_with_messages(recipient_id)
      end

      # -- ApplicationForm --
      def self.entity_type
        return Case
      end
    end
  end
end
