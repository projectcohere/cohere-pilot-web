class AddEnrollerToCases < ActiveRecord::Migration[6.0]
  def change
    change_table(:cases) do |t|
      t.belongs_to(:enroller, null: false)
    end
  end
end
