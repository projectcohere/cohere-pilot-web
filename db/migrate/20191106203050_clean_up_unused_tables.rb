class CleanUpUnusedTables < ActiveRecord::Migration[6.0]
  def up
    drop_table(:accounts)
    drop_table(:households)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
