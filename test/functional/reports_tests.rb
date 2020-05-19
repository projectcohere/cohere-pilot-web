require "test_helper"

class AdminTests < ActionDispatch::IntegrationTest
  # -- create --
  test "can't fill out the new report form without permission" do
    get("/reports")
    assert_redirected_to("/sign-in")

    user_rec = users(:source_1)
    get(auth("/reports/new", as: user_rec))
    assert_redirected_to("/cases")
  end

  test "fill out the new report form as an agent admin" do
    user_rec = users(:agent_1)

    get(auth("/reports/new", as: user_rec))
    assert_response(:success)
    assert_select(".PageHeader-title", text: /Reports/)
    assert_select("option", 5)
  end

  test "fill out the new report form as an enroller admin" do
    user_rec = users(:enroller_1)

    get(auth("/reports/new", as: user_rec))
    assert_response(:success)
    assert_select(".PageHeader-title", text: /Reports/)
    assert_select("option", 5)
  end

  test "can't create a report without permission" do
    post("/reports")
    assert_redirected_to("/sign-in")

    user_rec = users(:source_1)
    get(auth("/reports", as: user_rec))
    assert_redirected_to("/cases")
  end

  test "show errors when creating an invalid report" do
    user_rec = users(:agent_1)

    post(auth("/reports", as: user_rec), params: {
      report: {
        report: "accounting",
        start_date: 1.days.ago,
        end_date: 2.days.ago,
      }
    })
  end
end
