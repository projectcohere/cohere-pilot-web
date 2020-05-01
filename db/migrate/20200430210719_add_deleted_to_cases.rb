class AddDeletedToCases < ActiveRecord::Migration[6.0]
  def change
    add_column(:cases, :deleted, :boolean, default: false, null: false)
    add_index(:cases, :deleted)
  end
end
