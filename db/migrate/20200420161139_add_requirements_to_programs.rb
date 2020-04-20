class AddRequirementsToPrograms < ActiveRecord::Migration[6.0]
  def change
    change_table(:programs) do |t|
      t.json(:requirements, null: false, default: {})
    end
  end
end
