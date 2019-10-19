class RecipientTests < ActiveSupport::TestCase
  test "can be constructed from a record" do
    recipient = Recipient.from_record(recipients(:recipient_2))
    assert_not_nil(recipient.record)
    assert_not_nil(recipient.id)
    assert_not_nil(recipient.name)
    assert_not_nil(recipient.household)
    assert_length(recipient.household.income_history, 1)
  end
end
