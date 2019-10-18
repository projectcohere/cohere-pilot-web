require "test_helper"

class CasesTests < ActionDispatch::IntegrationTest
  # -- list --
  test "can't list cases if signed-out" do
    get("/cases")
    assert_redirected_to("/sign-in")
  end

  test "can't list cases without permission" do
    user = users(:supplier_1)
    get(auth("/cases", as: user))
    assert_redirected_to("/cases/inbound")
  end

  test "can list incomplete cases as an operator" do
    get(auth("/cases"))
    assert_response(:success)
    assert_select(".Main-title", text: /Cases/)
    assert_select(".CaseCell", 4)
  end

  test "can list pending cases for my org as an enroller" do
    user = users(:enroller_1)
    get(auth("/cases", as: user))
    assert_response(:success)
    assert_select(".Main-title", text: /Cases/)
    assert_select(".CaseCell", 1)
  end

  test "can list opened cases as a dhs partner" do
    user = users(:dhs_1)
    get(auth("/cases", as: user))
    assert_response(:success)
    assert_select(".Main-title", text: /Cases/)
    assert_select(".CaseCell", 2)
  end

  # -- list/inbound
  test "can't list inbound cases if signed-out" do
    get("/cases/inbound")
    assert_redirected_to("/sign-in")
  end

  test "can't list inbound cases without permission" do
    user = users(:cohere_1)
    get(auth("/cases/inbound", as: user))
    assert_redirected_to("/cases")
  end

  test "can list inbound cases with permission" do
    user = users(:supplier_1)
    get(auth("/cases/inbound", as: user))
    assert_response(:success)
    assert_select(".Main-title", text: /Inbound Cases/)
  end

  # -- create --
  test "can't add an inbound case if signed-out" do
    get("/cases/new")
    assert_redirected_to("/sign-in")
  end

  test "can't add an inbound case without permission" do
    user = users(:cohere_1)
    get(auth("/cases/new", as: user))
    assert_redirected_to("/cases")
  end

  test "can add a inbound case with permission" do
    user = users(:supplier_1)
    get(auth("/cases/new", as: user))
    assert_response(:success)
    assert_select(".Main-title", text: /Add a Case/)
  end

  test "can create an inbound case with permission" do
    user = users(:supplier_1)
    post(auth("/cases", as: user), params: {
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

  test "can't create an incomplete inbound case" do
    user = users(:supplier_1)
    post(auth("/cases", as: user), params: {
      case: {
        first_name: "Janice",
      }
    })

    assert_response(:success)
  end

  # -- edit --
  test "can't edit a case if signed-out" do
    kase = cases(:incomplete_1)
    get("/cases/#{kase.id}")
    assert_redirected_to("/sign-in")
  end

  test "can't edit a case without permission" do
    user = users(:supplier_1)
    kase = Case.from_record(cases(:incomplete_2))
    get(auth("/cases/#{kase.id}/edit", as: user))
    assert_redirected_to("/cases/inbound")
  end

  test "can edit a case with permission" do
    kase = Case.from_record(cases(:incomplete_1))
    get(auth("/cases/#{kase.id}/edit"))
    assert_response(:success)
    assert_select(".Main-title", text: /#{kase.recipient.name}/)
  end

  test "can edit an in-org, pending case as an enroller" do
    user = users(:enroller_1)
    kase = Case.from_record(cases(:incomplete_2))
    get(auth("/cases/#{kase.id}/edit", as: user))
    assert_response(:success)
    assert_select(".Main-title", text: /#{kase.recipient.name}/)
  end

  test "can edit an opened case as dhs" do
    user = users(:dhs_1)
    kase = Case.from_record(cases(:incomplete_1))
    get(auth("/cases/#{kase.id}/edit", as: user))
    assert_response(:success)
    assert_select(".Main-title", text: /#{kase.recipient.name}/)
  end

  # -- update --
  test "can update a case's household information" do
    skip

    user = users(:dhs_1)
    kase = Case.from_record(cases(:incomplete_1))
    put(auth("/cases/#{kase.id}", as: user), params: {
      case: {
        mdhhs_number: "12345",
        household_size: "5",
        incomes_attributes: {
          month: "October",
          amount: "$500"
        }
      }
    })

    assert_redirected_to("/cases")
  end
end
