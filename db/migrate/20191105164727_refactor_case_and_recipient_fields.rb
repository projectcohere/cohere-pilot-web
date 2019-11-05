class RefactorCaseAndRecipientFields < ActiveRecord::Migration[6.0]
  def change
    change_table(:cases) do |t|
      t.string(:account_number, null: false)
      t.string(:account_arrears, null: false)
    end

    change_table(:recipients) do |t|
      t.string(:dhs_household_size)
      t.string(:dhs_household_income)
    end
  end
end
