require "test_helper"

class CasesTests < ActionDispatch::IntegrationTest
  test "can't view unless signed-in" do
    get("/cases")
    assert_redirected_to("/sign-in")
  end

  test "can view incomplete cases as an operator" do
    get("/cases?as=#{users(:cohere_1).id}")
    assert_response(:success)
    assert_select(".Main-title", text: /Cases/)
    assert_select(".CaseCell", 4)
  end

  test "can view pending cases for my org as an enroller" do
    sign_in(users(:enroller_1))

    get("/cases")
    assert_response(:success)
    assert_select(".Main-title", text: /Cases/)
    assert_select(".CaseCell", 1)
  end
end
