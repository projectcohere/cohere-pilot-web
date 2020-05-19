class AddDietaryRestrictionsToCases < ActiveRecord::Migration[6.0]
  def change
    change_table(:cases) do |t|
      t.boolean(:dietary_restrictions)
    end
  end
end
