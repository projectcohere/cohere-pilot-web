class AddStatusToChatMessages < ActiveRecord::Migration[6.0]
  def change
    change_table(:chat_messages) do |t|
      t.integer(:status, default: 0, null: false)
      t.string(:remote_id)
      t.index(:remote_id)
    end
  end
end
