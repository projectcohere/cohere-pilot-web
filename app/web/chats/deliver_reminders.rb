module Chats
  class DeliverReminders < ApplicationWorker
    schedule(
      name: "Every 5 minutes",
      cron: "*/5 * * * *"
    )

    # -- lifetime --
    def initialize(chat_repo: Chat::Repo.get)
      @chat_repo = chat_repo
    end

    ## -- command --
    def call
      chat_ids = @chat_repo.find_all_ids_for_reminder1
      chat_ids.each do |chat_id|
        DeliverReminder.perform_async(chat_id)
      end
    end

    alias :perform :call
  end
end
