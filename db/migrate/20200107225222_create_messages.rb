class CreateMessages < ActiveRecord::Migration[6.0]
  def change
    create_table(:chat_messages) do |t|
      t.integer(:mtype, null: false, default: 0)
      t.string(:body)
      t.string(:sender, null: false)
      t.belongs_to(:chat, null: false)
      t.timestamps
    end

    remove_column(:chats, :messages, :jsonb, default: [])
  end
end
