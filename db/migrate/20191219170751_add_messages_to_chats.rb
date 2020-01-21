class AddMessagesToChats < ActiveRecord::Migration[6.0]
  def change
    change_table(:chats) do |t|
      t.jsonb(:messages, default: [])
    end
  end
end
