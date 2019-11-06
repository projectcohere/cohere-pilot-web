class AssociateDocumentsToCase < ActiveRecord::Migration[6.0]
  def up
    change_table(:documents) do |t|
      t.remove(:recipient_id)
      t.belongs_to(:case, null: false)
    end
  end

  def down
    change_table(:documents) do |t|
      t.remove(:case_id)
      t.belongs_to(:recipient, null: false)
    end
  end
end
