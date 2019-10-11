class AddStatusToCases < ActiveRecord::Migration[6.0]
  def change
    change_table(:cases) do |t|
      t.integer(:status, default: 0)
    end

    add_index(:cases, :status)
  end
end
