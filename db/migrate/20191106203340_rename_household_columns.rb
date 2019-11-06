class RenameHouseholdColumns < ActiveRecord::Migration[6.0]
  def change
    change_table(:recipients) do |t|
      t.rename(:household_size, :household_size)
      t.rename(:household_income, :household_income)
    end
  end
end
