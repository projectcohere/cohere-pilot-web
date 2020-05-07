class AddPriorityToPrograms < ActiveRecord::Migration[6.0]
  def change
    change_table(:programs) do |t|
      t.integer(:priority, null: false, default: 0)
      t.index(:priority)
    end
  end
end
