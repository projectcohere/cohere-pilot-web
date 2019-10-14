class CaseTests < ActiveSupport::TestCase
  test "incomplete when completed date is missing" do
    kase = Case.new(
      id: nil,
      recipient: nil,
      enroller: nil,
      status: nil,
      updated_at: nil,
      completed_at: nil
    )

    assert(kase.incomplete?)
  end
end
