require "test_helper"

class Enroller
  class RepoTests < ActiveSupport::TestCase
    test "maps a record" do
      enroller = Enroller::Repo.map_record(enrollers(:enroller_1))
      assert_not_nil(enroller.id)
      assert_not_nil(enroller.name)
    end
  end
end
