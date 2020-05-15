require "test_helper"

class AdminTests < ActionDispatch::IntegrationTest
  # -- view --
  test "can't view admin settings without permission" do
    get("/admin")
    assert_redirected_to("/sign-in")

    user_rec = users(:source_1)
    get(auth("/admin", as: user_rec))
    assert_redirected_to("/cases")
  end

  test "can view admin settings as an agent" do
    user_rec = users(:agent_1)

    get(auth("/admin", as: user_rec))
    assert_response(:success)
    assert_select(".PageHeader-title", text: /Admin/)
  end

  # -- hours --
  test "can't update working hours without permission" do
    assert_raises(ActionController::RoutingError) do
      patch("/admin/hours/on")
    end

    user_rec = users(:source_1)
    assert_raises(ActionController::RoutingError) do
      patch(auth("/admin/hours/off", as: user_rec))
    end
  end

  test "start working hours as an agent" do
    user_rec = users(:agent_1)

    act = -> do
      patch(auth("/admin/hours/on", as: user_rec))
    end

    assert_changes(
      -> { Settings.get.working_hours? },
      &act
    )

    assert_redirected_to("/admin")
  end

  test "stop working hours as an agent" do
    Settings.get.working_hours = true
    user_rec = users(:agent_1)

    act = -> do
      patch(auth("/admin/hours/off", as: user_rec))
    end

    assert_changes(
      -> { Settings.get.working_hours? },
      &act
    )

    assert_redirected_to("/admin")
  end
end
