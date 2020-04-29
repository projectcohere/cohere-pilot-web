class RemovePrimaryResidence < ActiveRecord::Migration[6.0]
  def change
    remove_column(:recipients, :household_primary_residence, :boolean, default: true, null: false)
  end
end
