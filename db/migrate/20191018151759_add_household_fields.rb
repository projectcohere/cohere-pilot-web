class AddHouseholdFields < ActiveRecord::Migration[6.0]
  def change
    change_table(:recipients) do |t|
      t.string(:dhs_number)
    end

    create_table(:households) do |t|
      t.belongs_to(:recipient)
      t.string(:size, null: false)
      t.jsonb(:income_history, null: false)
      t.timestamps
    end
  end
end
