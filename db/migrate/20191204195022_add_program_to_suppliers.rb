class AddProgramToSuppliers < ActiveRecord::Migration[6.0]
  def change
    change_table(:suppliers) do |t|
      t.integer(:program, default: 0)
      t.index(:program)
    end
  end
end
