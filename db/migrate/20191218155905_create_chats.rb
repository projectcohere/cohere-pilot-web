class CreateChats < ActiveRecord::Migration[6.0]
  def change
    create_table(:chats) do |t|
      t.string(:remember_token, limit: 128)
      t.datetime(:remember_token_expires_at)
      t.belongs_to(:recipient)
      t.timestamps
    end
  end
end
