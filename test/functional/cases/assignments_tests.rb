require "test_helper"

module Cases
  class AssignmentsTests < ActionDispatch::IntegrationTest
    test "can't self-assign to a case if signed-out" do
      assert_raises(ActionController::RoutingError) do
        post("/cases/3/assignments")
      end
    end

    test "can't self-assign to a case without permission" do
      user_rec = users(:supplier_1)

      assert_raises(ActionController::RoutingError) do
        post("/cases/3/assignments")
      end
    end

    test "self-assign to a case as a cohere user" do
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
  end
end
