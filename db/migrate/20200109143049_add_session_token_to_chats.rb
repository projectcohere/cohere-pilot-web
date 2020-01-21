class AddSessionTokenToChats < ActiveRecord::Migration[6.0]
  def change
    change_table(:chats) do |t|
      t.rename(:recipient_token, :invitation_token)
      t.rename(:recipient_token_expires_at, :invitation_token_expires_at)
      t.string(:session_token)
      t.index(:session_token, unique: true)
    end
  end
end
