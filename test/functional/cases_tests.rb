require "test_helper"

class CasesTests < ActionDispatch::IntegrationTest
  # -- list --
  # -- list/root
  test "can't list cases if signed-out" do
    get("/cases")
    assert_redirected_to("/sign-in")
  end

  test "can't list cases without permission" do
    user_rec = users(:supplier_1)

    get(auth("/cases", as: user_rec))
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
    user_rec = users(:cohere_1)

    get(auth("/cases/enroller", as: user_rec))
    assert_redirected_to(%r[/cases(?!/enroller)])
  end

  test "can list enroller cases for my org as an enroller" do
    user_rec = users(:enroller_1)

    get(auth("/cases/enroller", as: user_rec))
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
    user_rec = users(:cohere_1)

    get(auth("/cases/supplier", as: user_rec))
    assert_redirected_to(%r[/cases(?!/supplier)])
  end

  test "can list supplier cases with permission" do
    user_rec = users(:supplier_1)

    get(auth("/cases/supplier", as: user_rec))
    assert_response(:success)
    assert_select(".Main-title", text: /Supplier Cases/)
  end

  # -- list/dhs
  test "can't list dhs cases if signed-out" do
    get("/cases/dhs")
    assert_redirected_to("/sign-in")
  end

  test "can't list dhs cases without permission" do
    user_rec = users(:cohere_1)

    get(auth("/cases/dhs", as: user_rec))
    assert_redirected_to(%r[/cases(?!/dhs)])
  end

  test "can list dhs cases with permission" do
    user_rec = users(:dhs_1)

    get(auth("/cases/dhs", as: user_rec))
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
    user_rec = users(:cohere_1)

    get(auth("/cases/supplier/new", as: user_rec))
    assert_redirected_to(%r[/cases(?!/supplier)])
  end

  test "open a case with permission" do
    user_rec = users(:supplier_1)

    get(auth("/cases/supplier/new", as: user_rec))
    assert_response(:success)
    assert_select(".Main-title", text: /Add a Case/)
  end

  test "save an opened case with permission" do
    user_rec = users(:supplier_1)

    post(auth("/cases/supplier", as: user_rec), params: {
      case: {
        first_name: "Janice",
        last_name: "Sample",
        phone_number: Faker::Number.number(digits: 10),
        street: "123 Test Street",
        city: "Testopolis",
        state: "Testissippi",
        zip: "11111",
        account_number: "22222",
        arrears: "1000.00"
      }
    })

    assert_present(flash[:notice])
    assert_redirected_to("/cases/supplier")

    send_all_emails!
    assert_emails(1)
    assert_select_email do
      assert_select("a", text: /Janice Sample/) do |el|
        assert_match(%r[#{ENV["HOST"]}/cases/\d+/edit], el[0][:href])
      end
    end
  end

  test "show errors when opening an invalid case" do
    user_rec = users(:supplier_1)

    post(auth("/cases/supplier", as: user_rec), params: {
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
    case_rec = cases(:submitted_1)

    get("/cases/enroller/#{case_rec.id}")
    assert_redirected_to("/sign-in")
  end

  test "can't view an submitted case without permission" do
    user_rec = users(:cohere_1)
    case_rec = cases(:submitted_1)

    get(auth("/cases/enroller/#{case_rec.id}", as: user_rec))
    assert_redirected_to(%r[/cases(?!/enroller)])
  end

  test "view a submitted case" do
    user_rec = users(:enroller_1)
    case_rec = cases(:submitted_1)
    kase = Case::Repo.map_record(case_rec)

    get(auth("/cases/enroller/#{kase.id}", as: user_rec))
    assert_response(:success)
    assert_select(".Main-title", text: /#{kase.recipient.profile.name}/)
  end

  # -- edit --
  test "can't edit a case if signed-out" do
    case_rec = cases(:submitted_1)

    get("/cases/#{case_rec.id}/edit")
    assert_redirected_to("/sign-in")
  end

  test "edit a case" do
    user_rec = users(:cohere_1)
    case_rec = cases(:submitted_1)
    kase = Case::Repo.map_record(case_rec)

    get(auth("/cases/#{kase.id}/edit", as: user_rec))
    assert_response(:success)
    assert_select(".Main-title", text: /#{kase.recipient.profile.name}/)
  end

  test "save an edited case" do
    user_rec = users(:cohere_1)
    case_rec = cases(:pending_2)

    patch(auth("/cases/#{case_rec.id}", as: user_rec), params: {
      case: {
        status: :submitted,
        dhs_number: "1A2B3C"
      }
    })

    assert_redirected_to("/cases")
    assert_present(flash[:notice])

    send_all_emails!
    assert_emails(1)
    assert_select_email do
      assert_select("a", text: /Danice Sample/) do |el|
        assert_match(%r[#{ENV["HOST"]}/cases/\d+], el[0][:href])
      end
    end
  end

  test "show errors for an invalid case" do
    user_rec = users(:cohere_1)
    case_rec = cases(:pending_2)

    patch(auth("/cases/#{case_rec.id}", as: user_rec), params: {
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
    case_rec = cases(:opened_1)

    get("/cases/dhs/#{case_rec.id}/edit")
    assert_redirected_to("/sign-in")
  end

  test "can't edit a dhs case without permission" do
    user_rec = users(:supplier_1)
    case_rec = cases(:submitted_1)

    get(auth("/cases/dhs/#{case_rec.id}/edit", as: user_rec))
    assert_redirected_to(%r[/cases(?!/dhs)])
  end

  test "can edit an opened case with permission" do
    user_rec = users(:dhs_1)
    case_rec = cases(:opened_1)
    kase = Case::Repo.map_record(case_rec)

    get(auth("/cases/dhs/#{kase.id}/edit", as: user_rec))
    assert_response(:success)
    assert_select(".Main-title", text: /#{kase.recipient.profile.name}/)
  end

  test "can update an opened case" do
    user_rec = users(:dhs_1)
    kase = Case::Repo.map_record(cases(:opened_1))

    patch(auth("/cases/dhs/#{kase.id}", as: user_rec), params: {
      case: {
        dhs_number: "12345",
        household_size: "5",
        income: "500"
      }
    })

    assert_redirected_to("/cases/dhs")
    assert_present(flash[:notice])
  end
end
