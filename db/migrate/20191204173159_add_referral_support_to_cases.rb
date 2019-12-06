class AddReferralSupportToCases < ActiveRecord::Migration[6.0]
  def change
    change_table(:cases) do |t|
      t.belongs_to(:referring_case)
    end

    change_column_null(:cases, :supplier_account_number, true, "")
    change_column_null(:cases, :supplier_account_arrears_cents, true, 0)
  end
end
