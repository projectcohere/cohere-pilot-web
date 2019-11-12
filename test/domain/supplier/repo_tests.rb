require "test_helper"

class Supplier
  class RepoTests < ActiveSupport::TestCase
    test "maps a record" do
      supplier = Supplier::Repo.map_record(suppliers(:supplier_1))
      assert_not_nil(supplier.id)
      assert_not_nil(supplier.name)
    end
  end
end
