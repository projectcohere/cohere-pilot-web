class MakeCaseSupplierOptional < ActiveRecord::Migration[6.0]
  def change
    change_column_null(:cases, :supplier_id, true)
    change_column_default(:programs, :contracts, from: nil, to: [])
  end
end
