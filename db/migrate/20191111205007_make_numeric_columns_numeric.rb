class MakeNumericColumnsNumeric < ActiveRecord::Migration[6.0]
  def up
    cast_to_integer = -> (key) do
      [key, "integer USING CAST(#{key} AS integer)"]
    end

    change_column(:cases, *cast_to_integer.(:account_arrears), null: false)
    rename_column(:cases, :account_arrears, :account_arrears_cents)
    change_column(:recipients, *cast_to_integer.(:household_size))
    change_column(:recipients, *cast_to_integer.(:household_income))
    rename_column(:recipients, :household_income, :household_income_cents)
  end

  def down
    rename_column(:cases, :account_arrears_cents, :account_arrears)
    change_column(:cases, :account_arrears, :string, null: false)
    change_column(:recipients, :household_size, :string)
    rename_column(:recipients, :household_income_cents, :household_income)
    change_column(:recipients, :household_income, :string)
  end
end
