class CreateEvents < ActiveRecord::Migration[6.0]
  def change
    create_table(:events) do |t|
      t.json(:data, null: false)
      t.datetime(:created_at, null: false)
    end
  end
end
