class RemoveChatSession < ActiveRecord::Migration[6.0]
  def change
    remove_column(:chats, :session_token, :string)
  end
end
