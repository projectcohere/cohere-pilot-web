class AddSmsFieldsToChats < ActiveRecord::Migration[6.0]
  def change
    change_table(:chats) do |t|
      t.string(:sms_conversation_id)
      t.integer(:sms_conversation_notification, default: 0, null: false)
      t.index(:sms_conversation_notification)
      t.index(:updated_at)
    end
  end
end
