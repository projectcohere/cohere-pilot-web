class RenameChatAuthToken < ActiveRecord::Migration[6.0]
  def change
    change_table(:chats) do |t|
      t.rename(:remember_token, :recipient_token)
      t.rename(:remember_token_expires_at, :recipient_token_expires_at)
    end
  end
end
