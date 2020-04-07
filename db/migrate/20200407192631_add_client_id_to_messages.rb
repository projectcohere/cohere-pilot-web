class AddClientIdToMessages < ActiveRecord::Migration[6.0]
  def change
    change_table(:chat_messages) do |t|
      # TODO: make this nonnull in a follow-on migration
      t.string(:client_id)
    end
  end
end
