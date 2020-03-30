class RemoveOrganizations < ActiveRecord::Migration[6.0]
  def up
    # clean up user <-> partner relationship
    remove_column(:users, :organization_type, :string, null: false)
    remove_column(:users, :organization_id, :string, null: false)
    change_column_null(:users, :partner_id, false)

    # drop unused tables
    drop_table(:suppliers)
    drop_table(:enrollers)

    # rename columns
    rename_column(:partners, :membership_class, :membership)
  end

  def down
    fail(ActiveRecord::IrreversibleMigration)
  end
end
