class AddActivityToCases < ActiveRecord::Migration[6.0]
  def change
    change_table(:cases) do |t|
      t.boolean(:has_new_activity, default: false, null: false)
    end
  end
end
