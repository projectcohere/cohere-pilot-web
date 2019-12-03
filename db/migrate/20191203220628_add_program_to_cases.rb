class AddProgramToCases < ActiveRecord::Migration[6.0]
  def change
    change_table(:cases) do |t|
      t.integer(:program, default: 0)
    end
  end
end
