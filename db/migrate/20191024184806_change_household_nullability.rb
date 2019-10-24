class ChangeHouseholdNullability < ActiveRecord::Migration[6.0]
  def change
    change_column_null(:households, :size, true, "0")
    change_column_null(:households, :income_history, true, [])
  end
end
