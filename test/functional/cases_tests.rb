require "test_helper"

class CasesTests < ActionDispatch::IntegrationTest
  # -- list --
  test "can't list cases if signed-out" do
    get("/cases")
    assert_redirected_to("/sign-in")
  end

  test "can list cases as a supplier" do
    user_rec = users(:supplier_1)

    get(auth("/cases", as: user_rec))
    assert_response(:success)
    assert_select(".Main-title", text: /Inbound Cases/)
    assert_select(".CaseCell", 0)
  end

  test "can list opened cases as a dhs user" do
    user_rec = users(:dhs_1)

    get(auth("/cases", as: user_rec))
    assert_response(:success)
    assert_select(".Main-title", text: /Open Cases/)
    assert_select(".CaseCell", 4)
  end

  test "can list cases as an cohere user" do
    user_rec = users(:cohere_1)

    get(auth("/cases", as: user_rec))
    assert_response(:success)
    assert_select(".Main-title", text: /All Cases/)
    assert_select(".CaseCell", 6)
  end

  test "can list submitted cases as an enroller" do
    user_rec = users(:enroller_1)

    get(auth("/cases", as: user_rec))
    assert_response(:success)
    assert_select(".Main-title", text: /Submitted Cases/)
    assert_select(".CaseCell", 2)
  end

  # -- create --
  test "can't open a case if signed-out" do
    get("/cases/new")
    assert_redirected_to("/sign-in")
  end

  test "can't open a case without permission" do
    user_rec = users(:cohere_1)

    get(auth("/cases/new", as: user_rec))
    assert_redirected_to("/cases")
  end

  test "open a case as a supplier" do
    logger = fake_logging!

    user_rec = users(:supplier_1)

    get(auth("/cases/new", as: user_rec))
    assert_response(:success)
    assert_select(".Main-title", text: /Add a Case/)
    assert_match(/"event_name":"DidViewSupplierForm"/, logger.messages.last)
  end

  test "save an opened case as a supplier" do
    logger = fake_logging!

    user_rec = users(:supplier_1)

    post(auth("/cases", as: user_rec), params: {
      case: {
        first_name: "Janice",
        last_name: "Sample",
        phone_number: Faker::Number.number(digits: 10),
        street: "123 Test Street",
        city: "Testopolis",
        zip: "11111",
        account_number: "22222",
        arrears: "1000.00"
      }
    })

    assert_present(flash[:notice])
    assert_redirected_to("/cases")
    assert_match(/"event_name":"DidOpen"/, logger.messages.last)

    send_all_emails!
    assert_emails(1)
    assert_select_email do
      assert_select("a", text: /Janice Sample/) do |el|
        assert_match(%r[#{ENV["HOST"]}/cases/\d+/edit], el[0][:href])
      end
    end
  end

  test "show errors when opening an invalid case as a supplier" do
    user_rec = users(:supplier_1)

    post(auth("/cases", as: user_rec), params: {
      case: {
        first_name: "Janice",
      }
    })

    assert_response(:success)
    assert_present(flash[:alert])
  end

  # -- view --
  test "can't view a case if signed-out" do
    case_rec = cases(:submitted_1)

    get("/cases/#{case_rec.id}")
    assert_redirected_to("/sign-in")
  end

  test "can't view a case without permission" do
    case_rec = cases(:submitted_1)

    get(auth("/cases/#{case_rec.id}"))
    assert_redirected_to("/cases")
  end

  test "can't view another enroller's case as an enroller" do
    user_rec = users(:enroller_1)
    case_rec = cases(:submitted_2)

    assert_raises(ActiveRecord::RecordNotFound) do
      get(auth("/cases/#{case_rec.id}", as: user_rec))
    end
  end

  test "view a case as an enroller" do
    user_rec = users(:enroller_1)
    case_rec = cases(:submitted_1)
    kase = Case::Repo.map_record(case_rec)

    get(auth("/cases/#{kase.id}", as: user_rec))
    assert_response(:success)
    assert_select(".Main-title", text: /#{kase.recipient.profile.name}/)
  end

  # -- edit --
  test "can't edit a case if signed-out" do
    case_rec = cases(:submitted_1)

    get("/cases/#{case_rec.id}/edit")
    assert_redirected_to("/sign-in")
  end

  test "edit a case as a dhs user" do
    logger = fake_logging!

    user_rec = users(:dhs_1)
    case_rec = cases(:pending_1)

    get(auth("/cases/#{case_rec.id}/edit", as: user_rec))
    assert_response(:success)
    assert_select(".Main-title", text: /\w's case/)
    assert_match(/"event_name":"DidViewDhsForm"/, logger.messages.last)
  end

  test "save an edited case as a dhs user" do
    logger = fake_logging!

    user_rec = users(:dhs_1)
    case_rec = cases(:opened_1)

    patch(auth("/cases/#{case_rec.id}", as: user_rec), params: {
      case: {
        dhs_number: "12345",
        household_size: "5",
        income: "$500.00"
      }
    })

    assert_redirected_to("/cases")
    assert_present(flash[:notice])
    assert_match(/"event_name":"DidBecomePending"/, logger.messages.last)
  end

  test "edit a case as a cohere user" do
    user_rec = users(:cohere_1)
    case_rec = cases(:submitted_1)

    get(auth("/cases/#{case_rec.id}/edit", as: user_rec))
    assert_response(:success)
    assert_select(".Main-title", text: /\w+'s case/)
  end

  test "save an edited case as a cohere user" do
    logger = fake_logging!

    case_rec = cases(:pending_2)

    patch(auth("/cases/#{case_rec.id}"), params: {
      case: {
        status: :submitted,
        income: "$300.00"
      }
    })

    assert_redirected_to("/cases")
    assert_present(flash[:notice])
    assert_match(/"event_name":"DidSubmit"/, logger.messages.last)

    send_all_emails!
    assert_emails(1)
    assert_select_email do
      assert_select("a", text: /Danice Sample/) do |el|
        assert_match(%r[#{ENV["HOST"]}/cases/\d+], el[0][:href])
      end
    end
  end

  test "save a completed case" do
    logger = fake_logging!

    case_rec = cases(:submitted_1)

    patch(auth("/cases/#{case_rec.id}"), params: {
      case: {
        status: :approved
      }
    })

    assert_redirected_to("/cases")
    assert_present(flash[:notice])
    assert_match(/"event_name":"DidComplete"/, logger.messages.last)
  end

  test "save a signed contract" do
    Sidekiq::Testing.inline!

    case_rec = cases(:pending_2)

    act = ->() do
      patch(auth("/cases/#{case_rec.id}"), params: {
        case: {
          signed_contract: true
        }
      })
    end

    assert_difference(
      -> { Document::Record.count } => 1,
      -> { ActiveStorage::Attachment.count } => 1,
      -> { ActiveStorage::Blob.count } => 1,
      &act
    )

    assert_enqueued_jobs(1)

    pdf_text = text_from_pdf_file(case_rec.documents[0].file)
    assert_match(/MEAP\s*Agreement/, pdf_text)
    assert_match(/Danice\s*Sample/, pdf_text)
  end

  test "show errors when saving an invalid case as a cohere user" do
    case_rec = cases(:pending_2)

    patch(auth("/cases/#{case_rec.id}"), params: {
      case: {
        status: "submitted",
        dhs_number: nil
      }
    })

    assert_response(:success)
    assert_present(flash[:alert])
  end

  # -- approve/deny --
  test "can't approve/deny a case if signed-out" do
    assert_raises(ActionController::RoutingError) do
      patch("/cases/3/approve")
    end
  end

  test "can't approve/deny a case without permission" do
    user_rec = users(:supplier_1)

    assert_raises(ActionController::RoutingError) do
      patch(auth("/cases/4/deny", as: user_rec))
    end
  end

  test "can't approve/deny another enroller's case as an enroller" do
    user_rec = users(:enroller_1)
    case_rec = cases(:submitted_2)

    assert_raises(ActiveRecord::RecordNotFound) do
      patch(auth("/cases/#{case_rec.id}/deny", as: user_rec))
    end
  end

  test "can approve/deny a case as an enroller" do
    logger = fake_logging!

    user_rec = users(:enroller_1)
    case_rec = cases(:submitted_1)

    patch(auth("/cases/#{case_rec.id}/approve", as: user_rec))

    assert_redirected_to("/cases")
    assert_present(flash[:notice])
    assert_match(/"event_name":"DidComplete"/, logger.messages.last)

    send_all_emails!
    assert_emails(1)
    assert_select_email do
      assert_select("a", text: /Johnice Sample/) do |el|
        assert_match(%r[#{ENV["HOST"]}/cases/\d+], el[0][:href])
      end

      assert_select("p", text: /approved/)
    end
  end
end
