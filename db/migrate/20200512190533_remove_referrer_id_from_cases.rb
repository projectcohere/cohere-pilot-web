class RemoveReferrerIdFromCases < ActiveRecord::Migration[6.0]
  def change
    change_table(:cases) do |t|
      t.remove_belongs_to(:referrer)
    end
  end
end
