class RenameHasNewActivity < ActiveRecord::Migration[6.0]
  def change
    rename_column(:cases, :has_new_activity, :new_activity)
  end
end
