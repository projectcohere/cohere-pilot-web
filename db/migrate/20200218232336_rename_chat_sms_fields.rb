class RenameChatSmsFields < ActiveRecord::Migration[6.0]
  def change
    change_table(:chats) do |t|
      t.rename(:sms_conversation_notification, :notification)
    end
  end
end
