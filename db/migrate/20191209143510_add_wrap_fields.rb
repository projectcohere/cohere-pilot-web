class AddWrapFields < ActiveRecord::Migration[6.0]
  def change
    change_table(:cases) do |t|
      t.boolean(:supplier_account_active_service, default: true)
    end

    change_table(:recipients) do |t|
      t.integer(:household_ownership, default: 0)
      t.boolean(:household_primary_residence, default: true)
    end
  end
end
