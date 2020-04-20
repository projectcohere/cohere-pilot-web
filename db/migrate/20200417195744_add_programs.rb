class AddPrograms < ActiveRecord::Migration[6.0]
  def change
    change_table(:partners) do |t|
      time = Time.zone.now
      t.timestamps(default: time)
      t.change_default(:created_at, from: time, to: nil)
      t.change_default(:updated_at, from: time, to: nil)
    end

    create_table(:programs) do |t|
      t.string(:name, null: false)
      t.string(:contracts, array: true, null: false)
      t.timestamps
    end

    create_table(:partners_programs, id: false) do |t|
      t.belongs_to(:partner, null: false)
      t.belongs_to(:program, null: false)
    end

    change_table(:cases) do |t|
      # TODO: make this (null: false) in a follow on migration
      t.belongs_to(:program)
    end

    remove_column(:cases, :program, :integer, default: 0)
    remove_column(:partners, :programs, :integer, array: true)
  end
end
