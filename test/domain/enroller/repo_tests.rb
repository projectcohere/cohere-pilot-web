require "test_helper"

class Enroller
  class RepoTests < ActiveSupport::TestCase
    test "finds an enroller" do
      skip
    end

    test "finds the same default enroller" do
      repo = Enroller::Repo.get
      enroller = repo.find_default
      assert_not_nil(enroller)
      assert_equal(enroller, repo.find_default)
    end

    test "maps a record" do
      enroller = Enroller::Repo.map_record(enrollers(:enroller_1))
      assert_not_nil(enroller.id)
      assert_not_nil(enroller.name)
    end
  end
end
