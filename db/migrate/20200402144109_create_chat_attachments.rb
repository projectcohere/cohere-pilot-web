class CreateChatAttachments < ActiveRecord::Migration[6.0]
  def change
    create_table(:chat_attachments) do |t|
      t.string(:remote_url)
      t.belongs_to(:file)
      t.belongs_to(:message, null: false)
      t.timestamps
    end
  end
end
