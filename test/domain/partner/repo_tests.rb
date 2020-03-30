require "test_helper"

class Partner
  class RepoTests < ActiveSupport::TestCase
    test "maps a record" do
      partner = Partner::Repo.map_record(partners(:enroller_1))
      assert_not_nil(partner.id)
      assert_not_nil(partner.name)
      assert_not_nil(partner.membership)
    end
  end
end
