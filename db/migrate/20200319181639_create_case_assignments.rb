class CreateCaseAssignments < ActiveRecord::Migration[6.0]
  def change
    create_table(:case_assignments) do |t|
      t.belongs_to(:user, null: false)
      t.belongs_to(:case, null: false)
      t.string(:role_name, default: 0, null: false)
      t.index(%i[role_name user_id], unique: true)
    end
  end
end
