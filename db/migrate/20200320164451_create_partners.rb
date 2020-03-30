class CreatePartners < ActiveRecord::Migration[6.0]
  def change
    # Part 1 / 2, migrate from Enrollers & Suppliers to Partners
    # 1. Create & update tables, migrate data
    # 2. Drop old tables, set nullability

    # create new tables
    create_table(:partners) do |t|
      t.string(:name, null: false)
      t.integer(:membership_class, null: false)
      t.integer(:programs, array: true)
      t.index(:membership_class)
    end

    # add backwards-compatible support to existing tables
    change_table(:users) do |t|
      t.belongs_to(:partner)
    end

    change_table(:case_assignments) do |t|
      t.belongs_to(:partner)
    end

    add_index(:case_assignments, %i[user_id case_id partner_id],
      name: "by_natural_key_v2",
      unique: true,
    )
  end
end
