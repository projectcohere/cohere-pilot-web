require "test_helper"

class CaseAssignmentsTests < ActionDispatch::IntegrationTest
  include ActionCable::Channel::TestCase::Behavior

  # -- create --
  test "can't self-assign a case without permission" do
    user_rec = users(:supplier_1)

    assert_raises(ActionController::RoutingError) do
      post("/cases/3/assignments")
    end

    assert_raises(ActionController::RoutingError) do
      post(auth("/cases/3/assignments", as: user_rec))
    end
  end

  test "self-assign a case as a cohere user" do
    user_rec = users(:cohere_1)
    case_rec = cases(:opened_2)

    act = -> do
      post(auth("/cases/#{case_rec.id}/assignments", as: user_rec))
    end

    assert_difference(
      -> { Case::Assignment::Record.count } => 1,
      &act
    )

    assert_redirected_to("/cases")
    assert_present(flash[:notice])

    assert_matching_broadcast_on(case_activity_for(:cohere_1)) do |msg|
      assert_equal(msg["name"], "DID_ASSIGN_USER")
      assert_entry(msg["data"], "case_id")
    end
  end

  test "self-assign a case a dhs user" do
    user_rec = users(:dhs_1)
    case_rec = cases(:opened_2)

    act = -> do
      post(auth("/cases/#{case_rec.id}/assignments", as: user_rec))
    end

    assert_difference(
      -> { Case::Assignment::Record.count } => 1,
      &act
    )

    assert_redirected_to("/cases")
    assert_present(flash[:notice])

    assert_matching_broadcast_on(case_activity_for(:governor_1)) do |msg|
      assert_equal(msg["name"], "DID_ASSIGN_USER")
      assert_entry(msg["data"], "case_id")
    end
  end

  test "can't self-assign another enroller's case as an enroller user" do
    user_rec = users(:enroller_1)
    case_rec = cases(:submitted_2)

    assert_raises(ActiveRecord::RecordNotFound) do
      post(auth("/cases/#{case_rec.id}/assignments", as: user_rec))
    end
  end

  test "self-assign a case as an enroller user" do
    user_rec = users(:enroller_1)
    case_rec = cases(:submitted_1)
    case_rec.assignments.destroy_all

    act = -> do
      post(auth("/cases/#{case_rec.id}/assignments", as: user_rec))
    end

    assert_difference(
      -> { Case::Assignment::Record.count } => 1,
      &act
    )

    assert_redirected_to("/cases")
    assert_present(flash[:notice])

    assert_matching_broadcast_on(case_activity_for(:enroller_1)) do |msg|
      assert_equal(msg["name"], "DID_ASSIGN_USER")
      assert_entry(msg["data"], "case_id")
    end
  end

  # -- destroy --
  test "can't unassign a user without permission" do
    user_rec = users(:supplier_1)

    assert_raises(ActionController::RoutingError) do
      delete("/cases/3/assignments/1")
    end

    assert_raises(ActionController::RoutingError) do
      delete(auth("/cases/3/assignments/1", as: user_rec))
    end
  end

  test "unassign a user as a cohere user" do
    user_rec = users(:cohere_1)
    case_rec = cases(:opened_1)
    case_assignment_rec = case_rec.assignments.first

    act = -> do
      delete(auth("/cases/#{case_rec.id}/assignments/#{case_assignment_rec.partner_id}", as: user_rec))
    end

    assert_difference(
      -> { Case::Assignment::Record.count } => -1,
      &act
    )

    assert_redirected_to("/cases/#{case_rec.id}/edit")
    assert_present(flash[:notice])

    assert_matching_broadcast_on(case_activity_for(:cohere_1)) do |msg|
      assert_equal(msg["name"], "DID_UNASSIGN_USER")
      assert_entry(msg["data"], "case_id")
    end
  end
end
