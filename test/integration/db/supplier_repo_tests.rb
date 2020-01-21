require "test_helper"

module Db
  class SupplierRepoTests < ActiveSupport::TestCase
    test "finds a supplier" do
      supplier_repo = Supplier::Repo.new
      supplier_id = suppliers(:supplier_1).id

      supplier = supplier_repo.find(supplier_id)
      assert_not_nil(supplier)
      assert_equal(supplier.id, supplier_id)
    end

    test "finds suppliers by program" do
      supplier_repo = Supplier::Repo.new

      suppliers = supplier_repo.find_all_by_program(Program::Name::Wrap)
      assert_equal(suppliers.map(&:id), [suppliers(:supplier_3).id])
    end

    test "finds many suppliers" do
      supplier_repo = Supplier::Repo.new
      supplier_ids = [
        suppliers(:supplier_1).id,
        suppliers(:supplier_3).id
      ]

      suppliers = supplier_repo.find_many(supplier_ids)
      assert_length(suppliers, 2)
      assert_same_elements(suppliers.map(&:id), supplier_ids)
    end
  end
end
