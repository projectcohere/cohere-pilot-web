require "test_helper"

class Program
  class RepoTests < ActiveSupport::TestCase
    test "maps a record" do
      program_rec = programs(:water_0)

      program = Program::Repo.map_record(program_rec)
      assert_not_nil(program.id)
      assert_not_nil(program.name)
      assert_present(program.contracts)

      requirement = program.requirements[0]
      assert_present(program.requirements)
      assert_equal(requirement, Requirement::ContractPresent)
    end
  end
end
