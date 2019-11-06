class RefactorCaseAndRecipientFields < ActiveRecord::Migration[6.0]
  def change
    change_table(:cases) do |t|
      t.string(:account_number, null: false)
      t.string(:account_arrears, null: false)
    end

    change_table(:recipients) do |t|
      t.string(:household_size)
      t.string(:household_income)
    end
  end
end
