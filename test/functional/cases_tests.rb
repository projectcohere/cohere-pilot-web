require "test_helper"

class CasesTests < ActionDispatch::IntegrationTest
  test "can't view unless signed-in" do
    get "/cases"
    assert_redirected_to("/sign-in")
  end

  test "can view incomplete cases as an operator" do
    sign_in
    get "/cases"
    assert_response(:success)
    assert_select(".Main-title", text: /Cases/)
    assert_select(".Case", 2)
  end
end
