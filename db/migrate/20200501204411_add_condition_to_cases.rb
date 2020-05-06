class AddConditionToCases < ActiveRecord::Migration[6.0]
  def change
    remove_column(:cases, :deleted, :boolean, default: false, null: false)
    add_column(:cases, :condition, :integer, default: 0, null: false)
    add_index(:cases, :condition)
  end
end
