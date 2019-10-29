class CreateDocuments < ActiveRecord::Migration[6.0]
  def change
    create_table :documents do |t|
      t.string(:source_url, null: false)
      t.belongs_to(:recipient, null: false)
      t.index(:source_url, unique: true)
    end
  end
end
