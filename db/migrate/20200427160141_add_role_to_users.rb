class AddRoleToUsers < ActiveRecord::Migration[6.0]
  def change
    change_table(:users) do |t|
      t.integer(:role, default: 0, null: false)
    end

    change_table(:case_assignments) do |t|
      t.integer(:role, null: false)
    end

    remove_index(:case_assignments, column: %i[user_id case_id partner_id],
      name: "by_natural_key",
      unique: true,
    )

    add_index(:case_assignments, %i[user_id role case_id partner_id],
      name: "by_natural_key",
      unique: true,
    )
  end
end
