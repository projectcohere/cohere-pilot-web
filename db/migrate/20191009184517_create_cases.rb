class CreateCases < ActiveRecord::Migration[6.0]
  def change
    create_table(:cases) do |t|
      t.belongs_to(:recipient, null: false)
      t.datetime(:completed_at, precision: 6)
      t.timestamps
    end
  end
end
