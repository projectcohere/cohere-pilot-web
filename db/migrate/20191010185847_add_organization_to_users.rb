class AddOrganizationToUsers < ActiveRecord::Migration[6.0]
  def up
    change_table(:users) do |t|
      t.references(:organization, polymorphic: true)
    end

    change_column_null(:users, :organization_type, false)
  end

  def down
    change_table(:users) do |t|
      t.remove_references(:organization, polymorphic: true)
    end
  end
end
