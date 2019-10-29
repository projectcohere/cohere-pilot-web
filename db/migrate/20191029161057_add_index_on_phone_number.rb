class AddIndexOnPhoneNumber < ActiveRecord::Migration[6.0]
  def change
    change_table(:recipients) do |t|
      t.index(:phone_number, unique: true)
    end
  end
end
