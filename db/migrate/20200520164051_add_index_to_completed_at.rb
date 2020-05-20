class AddIndexToCompletedAt < ActiveRecord::Migration[6.0]
  def change
    change_table(:cases) do |t|
      t.index(:completed_at)
    end
  end
end
