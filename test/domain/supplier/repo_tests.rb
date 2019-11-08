require "test_helper"

class Supplier
  class RepoTests < ActiveSupport::TestCase
    test "finds a supplier" do
      repo = Supplier::Repo.new
      supplier_id = suppliers(:supplier_1).id
      supplier = repo.find(supplier_id)
      assert_not_nil(supplier)
      assert_equal(supplier.id, supplier_id)
    end

    test "finds many suppliers" do
      repo = Supplier::Repo.new
      supplier_ids = [
        suppliers(:supplier_1).id,
        suppliers(:supplier_2).id
      ]

      suppliers = repo.find_many(supplier_ids)
      assert_length(suppliers, 2)
      assert_same_elements(suppliers.map(&:id), supplier_ids)
    end

    test "maps a record" do
      supplier = Supplier::Repo.map_record(suppliers(:supplier_1))
      assert_not_nil(supplier.id)
      assert_not_nil(supplier.name)
    end
  end
end