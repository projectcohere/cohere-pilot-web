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
    assert_redirected_to(%r[/cases/supplier])
  end

  test "can list incomplete cases as an operator" do
    get(auth("/cases"))
    assert_response(:success)
    assert_select(".Main-title", text: /Cases/)
    assert_select(".CaseCell", 6)
  end

  # -- list/enroller
  test "can't list enroller cases if signed-out" do
    get("/cases/enroller")
    assert_redirected_to("/sign-in")
  end

  test "can't list enroller cases without permission" do
    user = users(:cohere_1)
    get(auth("/cases/enroller", as: user))
    assert_redirected_to(%r[/cases(?!/enroller)])
  end

  test "can list enroller cases for my org as an enroller" do
    user = users(:enroller_1)
    get(auth("/cases/enroller", as: user))
    assert_response(:success)
    assert_select(".Main-title", text: /Cases/)
    assert_select(".CaseCell", 2)
  end

  # -- list/supplier
  test "can't list supplier cases if signed-out" do
    get("/cases/supplier")
    assert_redirected_to("/sign-in")
  end

  test "can't list supplier cases without permission" do
    user = users(:cohere_1)
    get(auth("/cases/supplier", as: user))
    assert_redirected_to(%r[/cases(?!/supplier)])
  end

  test "can list supplier cases with permission" do
    user = users(:supplier_1)
    get(auth("/cases/supplier", as: user))
    assert_response(:success)
    assert_select(".Main-title", text: /Supplier Cases/)
  end

  # -- list/dhs
  test "can't list dhs cases if signed-out" do
    get("/cases/dhs")
    assert_redirected_to("/sign-in")
  end

  test "can't list dhs cases without permission" do
    user = users(:cohere_1)
    get(auth("/cases/dhs", as: user))
    assert_redirected_to(%r[/cases(?!/dhs)])
  end

  test "can list dhs cases with permission" do
    user = users(:dhs_1)
    get(auth("/cases/dhs", as: user))
    assert_response(:success)
    assert_select(".Main-title", text: /Cases/)
    assert_select(".CaseCell", 4)
  end

  # -- create --
  # -- create/supplier
  test "can't open a case if signed-out" do
    get("/cases/supplier/new")
    assert_redirected_to("/sign-in")
  end

  test "can't open a case without permission" do
    user = users(:cohere_1)
    get(auth("/cases/supplier/new", as: user))
    assert_redirected_to(%r[/cases(?!/supplier)])
  end

  test "open a case with permission" do
    user = users(:supplier_1)
    get(auth("/cases/supplier/new", as: user))
    assert_response(:success)
    assert_select(".Main-title", text: /Add a Case/)
  end

  test "save an opened case with permission" do
    user = users(:supplier_1)
    post(auth("/cases/supplier", as: user), params: {
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

    assert_present(flash[:notice])
    assert_redirected_to("/cases/supplier")

    perform_enqueued_jobs(queue: :mailers)
    assert_emails(2)
    assert_select_email do
      assert_select("a", text: /Janice Sample/) do |el|
        assert_match(/http:\/\/localhost\:3000\/cases\/(dhs\/)?\d+\/edit/, el[0][:href])
      end
    end
  end

  test "show errors when opening an invalid case" do
    user = users(:supplier_1)
    post(auth("/cases/supplier", as: user), params: {
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
    get("/cases/enroller/#{kase.id}")
    assert_redirected_to("/sign-in")
  end

  test "can't view an submitted case without permission" do
    user = users(:cohere_1)
    kase = cases(:submitted_1)
    get(auth("/cases/enroller/#{kase.id}", as: user))
    assert_redirected_to(%r[/cases(?!/enroller)])
  end

  test "view a submitted case" do
    user = users(:enroller_1)
    kase = Case::Repo.map_record(cases(:submitted_1))
    get(auth("/cases/enroller/#{kase.id}", as: user))
    assert_response(:success)
    assert_select(".Main-title", text: /#{kase.recipient.profile.name}/)
  end

  # -- edit --
  test "can't edit a case if signed-out" do
    kase = cases(:submitted_1)
    get("/cases/#{kase.id}/edit")
    assert_redirected_to("/sign-in")
  end

  test "edit a case" do
    user = users(:cohere_1)
    kase = Case::Repo.map_record(cases(:submitted_1))
    get(auth("/cases/#{kase.id}/edit", as: user))
    assert_response(:success)
    assert_select(".Main-title", text: /#{kase.recipient.profile.name}/)
  end

  test "save an edited case" do
    user = users(:cohere_1)
    kase = cases(:pending_2)

    patch(auth("/cases/#{kase.id}", as: user), params: {
      case: {
        status: :submitted,
        dhs_number: "1A2B3C"
      }
    })

    assert_redirected_to("/cases")
    assert_present(flash[:notice])

    # perform_enqueued_jobs(queue: :mailers)
    # assert_emails(1)
    # assert_select_email do
    #   assert_select("a", text: /Janice Sample/) do |el|
    #     assert_match(/http:\/\/localhost\:3000\/cases\/submitted\/\d+\/edit/, el[0][:href])
    #   end
    # end
  end

  test "show errors for an invalid case" do
    user = users(:cohere_1)
    kase = cases(:pending_2)

    patch(auth("/cases/#{kase.id}", as: user), params: {
      case: {
        status: "submitted",
        dhs_number: nil
      }
    })

    assert_response(:success)
    assert_present(flash[:alert])
  end

  # -- edit/dhs
  test "can't edit a dhs case if signed-out" do
    kase = cases(:opened_1)
    get("/cases/dhs/#{kase.id}/edit")
    assert_redirected_to("/sign-in")
  end

  test "can't edit a dhs case without permission" do
    user = users(:supplier_1)
    kase = Case::Repo.map_record(cases(:submitted_1))
    get(auth("/cases/dhs/#{kase.id}/edit", as: user))
    assert_redirected_to(%r[/cases(?!/dhs)])
  end

  test "can edit an opened case with permission" do
    user = users(:dhs_1)
    kase = Case::Repo.map_record(cases(:opened_1))
    get(auth("/cases/dhs/#{kase.id}/edit", as: user))
    assert_response(:success)
    assert_select(".Main-title", text: /#{kase.recipient.profile.name}/)
  end

  test "can update an opened case" do
    user = users(:dhs_1)
    kase = Case::Repo.map_record(cases(:opened_1))

    patch(auth("/cases/dhs/#{kase.id}", as: user), params: {
      case: {
        dhs_number: "12345",
        household_size: "5",
        income: "$500"
      }
    })

    assert_redirected_to("/cases/dhs")
    assert_present(flash[:notice])
  end
end
