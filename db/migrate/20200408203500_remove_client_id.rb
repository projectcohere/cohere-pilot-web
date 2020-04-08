class RemoveClientId < ActiveRecord::Migration[6.0]
  def change
    remove_column(:chat_messages, :client_id, :string)
  end
end
