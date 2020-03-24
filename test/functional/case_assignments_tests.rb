require "test_helper"

class CaseAssignmentsTests < ActionDispatch::IntegrationTest
  test "can't self-assign a case if signed-out" do
    assert_raises(ActionController::RoutingError) do
      post("/cases/3/assignments")
    end
  end

  test "can't self-assign a case without permission" do
    user_rec = users(:supplier_1)

    assert_raises(ActionController::RoutingError) do
      post("/cases/3/assignments")
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
  end
end
