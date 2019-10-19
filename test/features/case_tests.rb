class CaseTests < ActiveSupport::TestCase
  test "can be constructed from a record" do
    kase = Case.from_record(cases(:opened_1))
    assert_not_nil(kase.record)
    assert_not_nil(kase.id)
    assert_not_nil(kase.recipient)
    assert_not_nil(kase.enroller)
    assert_equal(kase.status, :opened)
  end
end
