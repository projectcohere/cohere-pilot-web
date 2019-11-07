class AddInboundCaseFields < ActiveRecord::Migration[6.0]
  def change
    change_table(:cases) do |t|
      t.belongs_to(:supplier, null: false)
    end

    change_table(:recipients) do |t|
      t.string(:street, null: false)
      t.string(:street2)
      t.string(:city, null: false)
      t.string(:state, null: false)
      t.string(:zip, null: false)
    end

    create_table(:accounts) do |t|
      t.belongs_to(:supplier)
      t.belongs_to(:recipient)
      t.string(:number, null: false)
      t.string(:arrears, null: false)
      t.timestamps
    end
  end
end
