class MakeWrapFieldsNonnull < ActiveRecord::Migration[6.0]
  def change
    change_column_null(:cases, :supplier_account_active_service, false)
    change_column_null(:recipients, :household_ownership, false)
    change_column_null(:recipients, :household_primary_residence, false)
  end
end
