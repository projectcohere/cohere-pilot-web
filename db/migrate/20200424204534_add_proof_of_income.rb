class AddProofOfIncome < ActiveRecord::Migration[6.0]
  def change
    change_table(:recipients) do |t|
      t.integer(:household_proof_of_income, default: 0, null: false)
    end

    change_column_null(:cases, :status, false)
  end
end
