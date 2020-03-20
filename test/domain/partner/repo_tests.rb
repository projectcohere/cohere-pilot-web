require "test_helper"

class Partner
  class RepoTests < ActiveSupport::TestCase
    test "maps a record" do
      enroller = Partner::Repo.map_record(partners(:enroller_1))
      assert_not_nil(enroller.id)
      assert_not_nil(enroller.name)
    end
  end
end
