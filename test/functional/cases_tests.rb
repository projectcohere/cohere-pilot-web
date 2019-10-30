require "test_helper"

class CasesTests < ActionDispatch::IntegrationTest
  # -- list --
  # -- list/root
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
    assert_select(".CaseCell", 6)
  end

  # -- list/submitted
  test "can't list submitted cases if signed-out" do
    get("/cases/submitted")
    assert_redirected_to("/sign-in")
  end

  test "can't list submitted cases without permission" do
    user = users(:cohere_1)
    get(auth("/cases/submitted", as: user))
    assert_redirected_to("/cases")
  end

  test "can list submitted cases for my org as an enroller" do
    user = users(:enroller_1)
    get(auth("/cases/submitted", as: user))
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

  # -- list/opened
  test "can't list opened cases if signed-out" do
    get("/cases/opened")
    assert_redirected_to("/sign-in")
  end

  test "can't list opened cases without permission" do
    user = users(:cohere_1)
    get(auth("/cases/opened", as: user))
    assert_redirected_to("/cases")
  end

  test "can list opened cases with permission" do
    user = users(:dhs_1)
    get(auth("/cases/opened", as: user))
    assert_response(:success)
    assert_select(".Main-title", text: /Cases/)
    assert_select(".CaseCell", 4)
  end

  # -- create --
  # -- create/inbound
  test "can't add an inbound case if signed-out" do
    get("/cases/inbound/new")
    assert_redirected_to("/sign-in")
  end

  test "can't add an inbound case without permission" do
    user = users(:cohere_1)
    get(auth("/cases/inbound/new", as: user))
    assert_redirected_to("/cases")
  end

  test "can add a inbound case with permission" do
    user = users(:supplier_1)
    get(auth("/cases/inbound/new", as: user))
    assert_response(:success)
    assert_select(".Main-title", text: /Add a Case/)
  end

  test "can create an inbound case with permission" do
    user = users(:supplier_1)
    post(auth("/cases/inbound", as: user), params: {
      case: {
        first_name: "Janice",
        last_name: "Sample",
        phone_number: Faker::PhoneNumber.phone_number,
        street: "123 Test Street",
        city: "Testopolis",
        state: "Testissippi",
        zip: "11111",
        account_number: "22222",
        arrears: "$1000.0"
      }
    })

    assert_redirected_to("/cases/inbound")
    assert_present(flash[:notice])
  end

  test "show errors for an invalid inbound case" do
    user = users(:supplier_1)
    post(auth("/cases/inbound", as: user), params: {
      case: {
        first_name: "Janice",
      }
    })

    assert_response(:success)
    assert_present(flash[:alert])
  end

  # -- view --
  # -- view/submitted
  test "can't view a submitted case if signed-out" do
    kase = cases(:submitted_1)
    get("/cases/submitted/#{kase.id}")
    assert_redirected_to("/sign-in")
  end

  test "can't view a submitted case without permission" do
    user = users(:cohere_1)
    kase = cases(:submitted_1)
    get(auth("/cases/submitted/#{kase.id}", as: user))
    assert_redirected_to("/cases")
  end

  test "can view a submitted case" do
    user = users(:enroller_1)
    kase = Case.from_record(cases(:submitted_1))
    get(auth("/cases/submitted/#{kase.id}", as: user))
    assert_response(:success)
    assert_select(".Main-title", text: /#{kase.recipient.name}/)
  end

  # -- edit --
  test "can't edit a case if signed-out" do
    kase = cases(:opened_1)
    get("/cases/#{kase.id}/edit")
    assert_redirected_to("/sign-in")
  end

  test "can edit a case" do
    user = users(:cohere_1)
    kase = Case.from_record(cases(:submitted_1))
    get(auth("/cases/#{kase.id}/edit", as: user))
    assert_response(:success)
    assert_select(".Main-title", text: /#{kase.recipient.name}/)
  end

  # -- edit/opened
  test "can't edit an opened case if signed-out" do
    kase = cases(:opened_1)
    get("/cases/opened/#{kase.id}/edit")
    assert_redirected_to("/sign-in")
  end

  test "can't edit an opened case without permission" do
    user = users(:supplier_1)
    kase = Case.from_record(cases(:submitted_1))
    get(auth("/cases/opened/#{kase.id}/edit", as: user))
    assert_redirected_to("/cases/inbound")
  end

  test "can edit an opened case with permission" do
    user = users(:dhs_1)
    kase = Case.from_record(cases(:opened_1))
    get(auth("/cases/opened/#{kase.id}/edit", as: user))
    assert_response(:success)
    assert_select(".Main-title", text: /#{kase.recipient.name}/)
  end

  test "can update a case" do
    user = users(:cohere_1)
    kase = cases(:pending_2)

    patch(auth("/cases/#{kase.id}", as: user), params: {
      case: {
        dhs_number: "1A2B3C"
      }
    })

    assert_redirected_to("/cases")
    assert_present(flash[:notice])
  end

  test "show errors for an invalid case" do
    user = users(:cohere_1)
    kase = cases(:pending_2)

    patch(auth("/cases/#{kase.id}", as: user), params: {
      case: {
        status: "submitted"
      }
    })

    assert_response(:success)
    assert_present(flash[:alert])
  end

  test "can update an opened case" do
    user = users(:dhs_1)
    kase = Case.from_record(cases(:opened_1))

    patch(auth("/cases/opened/#{kase.id}", as: user), params: {
      case: {
        dhs_number: "12345",
        household_size: "5",
        income_history: {
          "0": {
            month: "October",
            amount: "$500"
          }
        }
      }
    })

    assert_redirected_to("/cases/opened")
    assert_present(flash[:notice])
  end
end
