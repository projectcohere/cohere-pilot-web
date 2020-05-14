require "test_helper"

class AdminTests < ActionDispatch::IntegrationTest
  # -- list --
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
end
