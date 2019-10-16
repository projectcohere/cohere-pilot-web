require "test_helper"

class CasesTests < ActionDispatch::IntegrationTest
  # -- list --
  test "can only list cases if signed-in" do
    get("/cases")
    assert_redirected_to("/sign-in")
  end

  test "can list incomplete cases as an operator" do
    get(auth("/cases"))
    assert_response(:success)
    assert_select(".Main-title", text: /Cases/)
    assert_select(".CaseCell", 4)
  end

  test "can list pending cases for my org as an enroller" do
    get(auth("/cases", as: users(:enroller_1)))
    assert_response(:success)
    assert_select(".Main-title", text: /Cases/)
    assert_select(".CaseCell", 1)
  end

  test "can list opened cases as a dhs partner" do
    get(auth("/cases", as: users(:dhs_1)))
    assert_response(:success)
    assert_select(".Main-title", text: /Cases/)
    assert_select(".CaseCell", 2)
  end

  # -- list/inbound
  test "can list inbound cases as a supplier" do
    get(auth("/cases/inbound", as: users(:supplier_1)))
    assert_response(:success)
    assert_select(".Main-title", text: /Inbound Cases/)
  end

  # -- view --
  test "can't view a case unless signed-in" do
    kase = cases(:incomplete_1)
    get("/cases/#{kase.id}")
    assert_redirected_to("/sign-in")
  end

  test "can view a case as an operator" do
    kase = Case.from_record(cases(:incomplete_1))
    get(auth("/cases/#{kase.id}"))
    assert_response(:success)
    assert_select(".Main-title", text: /#{kase.recipient.name}/)
  end

  test "can view a pending case for my org as an enroller" do
    kase = Case.from_record(cases(:incomplete_2))
    get(auth("/cases/#{kase.id}", as: users(:enroller_1)))
    assert_response(:success)
    assert_select(".Main-title", text: /#{kase.recipient.name}/)
  end

  test "can't view a case as a supplier" do
    kase = Case.from_record(cases(:incomplete_2))
    get(auth("/cases/#{kase.id}", as: users(:supplier_1)))
    assert_redirected_to("/cases/inbound")
  end

  # -- create --
  test "can add a new case as a supplier" do
    get(auth("/cases/new", as: users(:supplier_1)))
    assert_response(:success)
    assert_select(".Main-title", text: /Add a Case/)
  end

  test "can't add a new case as an operator" do
    get(auth("/cases/new", as: users(:cohere_1)))
    assert_redirected_to("/cases")
  end

  test "can't add a new case as an enroller" do
    get(auth("/cases/new", as: users(:enroller_1)))
    assert_redirected_to("/cases")
  end

  test "can create a new case as a supplier" do
    post(auth("/cases", as: users(:supplier_1)), params: {
      case: {
        first_name: "Janice",
        last_name: "Sample",
        phone_number: "111-222-3333",
        street: "123 Test Street",
        city: "Testopolis",
        state: "Testissippi",
        zip: "11111",
        account_number: "22222",
        arrears: "$1000.0"
      }
    })

    assert_redirected_to("/cases/inbound")
  end

  test "can't create an incomplete case" do
    post(auth("/cases", as: users(:supplier_1)), params: {
      case: {
        first_name: "Janice",
      }
    })

    assert_response(:success)
  end
end
