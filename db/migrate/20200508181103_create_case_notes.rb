class CreateCaseNotes < ActiveRecord::Migration[6.0]
  def change
    create_table(:case_notes) do |t|
      t.string(:body, null: false)
      t.belongs_to(:case)
      t.belongs_to(:user)
      t.timestamps
    end
  end
end
