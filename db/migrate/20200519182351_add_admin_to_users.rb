class AddAdminToUsers < ActiveRecord::Migration[6.0]
  def change
    change_table(:users) do |t|
      t.boolean(:admin, null: false, default: false)
    end
  end
end
