class FixCaseAssignmentsIndex < ActiveRecord::Migration[6.0]
  def change
    add_index(:case_assignments, %i[role_name user_id case_id],
      name: "by_natural_key",
      unique: true,
    )

    remove_index(:case_assignments,
      column: %i[role_name user_id],
      unique: true,
    )
  end
end
