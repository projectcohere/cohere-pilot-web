class CaseTests < ActiveSupport::TestCase
  test "incomplete when completed date is missing" do
    kase = Case.new(
      recipient: nil,
      enroller: nil,
      updated_at: nil,
      completed_at: nil
    )

    assert(kase.incomplete?)
  end
end
