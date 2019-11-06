require "test_helper"

class EnrollerTests < ActiveSupport::TestCase
  test "can be constructed from a record" do
    enroller = Enroller::Repo.map_record(enrollers(:enroller_1))
    assert_not_nil(enroller.id)
  end
end
