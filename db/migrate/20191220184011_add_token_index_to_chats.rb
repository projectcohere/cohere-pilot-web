class AddTokenIndexToChats < ActiveRecord::Migration[6.0]
  def change
    change_table(:chats) do |t|
      t.remove_index(:recipient_id)
      t.index(:recipient_token, unique: true)
      t.index(:recipient_id, unique: true)
    end
  end
end
