class RemoveTypeFromMessages < ActiveRecord::Migration[6.0]
  def change
    remove_column(:chat_messages, :mtype, :integer)
  end
end
