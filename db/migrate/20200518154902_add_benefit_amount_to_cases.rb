class AddBenefitAmountToCases < ActiveRecord::Migration[6.0]
  def change
    change_table(:cases) do |t|
      t.integer(:benefit_amount_cents)
    end
  end
end
