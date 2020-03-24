class RemoveRoleFromCaseAssignments < ActiveRecord::Migration[6.0]
  def change
    remove_column(:case_assignments, :role_name, :string, default: 0, null: false)
    rename_index(:case_assignments, "by_natural_key_v2", "by_natural_key")
    change_column_null(:case_assignments, :partner_id, false)
  end
end
