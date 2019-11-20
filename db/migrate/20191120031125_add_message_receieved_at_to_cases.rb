class AddMessageReceievedAtToCases < ActiveRecord::Migration[6.0]
  def change
    change_table(:cases) do |t|
      t.datetime(:received_message_at, precision: 6)
    end
  end
end
