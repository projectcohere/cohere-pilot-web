require "test_helper"

class EnrollerTests < ActiveSupport::TestCase
  test "an enroller can be constructed from a record" do
    enroller = Enroller.from_record(enrollers(:enroller_1))
    assert_not_nil(enroller.id)
  end
end
