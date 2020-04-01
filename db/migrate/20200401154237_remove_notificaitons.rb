class RemoveNotificaitons < ActiveRecord::Migration[6.0]
  def change
    remove_column(:chats, :notification, :integer, default: 0, null: false)
    remove_column(:chats, :sms_conversation_id, :string)
  end
end
