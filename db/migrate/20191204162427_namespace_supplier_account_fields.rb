class NamespaceSupplierAccountFields < ActiveRecord::Migration[6.0]
  def change
    change_table(:cases) do |t|
      t.rename(:account_number, :supplier_account_number)
      t.rename(:account_arrears_cents, :supplier_account_arrears_cents)
    end
  end
end
