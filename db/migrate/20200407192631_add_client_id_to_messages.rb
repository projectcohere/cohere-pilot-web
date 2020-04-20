class AddClientIdToMessages < ActiveRecord::Migration[6.0]
  def change
    change_table(:chat_messages) do |t|
      t.string(:client_id)
    end
  end
end
