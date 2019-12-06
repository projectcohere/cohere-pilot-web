class RenameReferrer < ActiveRecord::Migration[6.0]
  def change
    change_table(:cases) do |t|
      t.rename(:referring_case_id, :referrer_id)
    end
  end
end
