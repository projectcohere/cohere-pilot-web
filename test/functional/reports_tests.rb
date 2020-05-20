require "test_helper"

class ReportsTests < ActionDispatch::IntegrationTest
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
    assert_select(".PageHeader-title", text: /New Report/)
    assert_select("option", 6)
  end

  test "fill out the new report form as an enroller admin" do
    user_rec = users(:enroller_1)

    get(auth("/reports/new", as: user_rec))
    assert_response(:success)
    assert_select(".PageHeader-title", text: /New Report/)
    assert_select("option", 5)
  end

  test "can't create a report without permission" do
    assert_raises(ActionController::RoutingError) do
      post("/reports.csv")
    end

    user_rec = users(:source_1)
    assert_raises(ActionController::RoutingError) do
      post(auth("/reports.csv", as: user_rec))
    end
  end

  test "create a report as an agent" do
    user_rec = users(:agent_1)

    post(auth("/reports.csv", as: user_rec), params: {
      report: {
        report: "accounting",
        start_date: 7.days.ago.to_date.to_s,
        end_date: 0.days.ago.to_date.to_s,
      }
    })

    assert_response(:success)
    assert_equal(response.media_type, "text/csv")

    csv_header = ""
    assert(response.body.starts_with?(csv_header))
    assert_equal(response.body.count("\n"), 3)
  end

  test "create a report as an enroller" do
    user_rec = users(:agent_1)
    program_rec = programs(:energy_0)

    post(auth("/reports.csv", as: user_rec), params: {
      report: {
        report: program_rec.id,
        start_date: 7.days.ago.to_date.to_s,
        end_date: 0.days.ago.to_date.to_s,
      }
    })

    assert_response(:success)
    assert_equal(response.media_type, "text/csv")

    csv_header = "Client ID,Date,Wayne County,First Name,Last Name,Residential Address,City,State,Zip,Cell Phone #,Household Size,Income Verification Type,Utility Company,Account Number,Arrears,Award Amount"
    assert(response.body.starts_with?(csv_header))
    assert_equal(response.body.count("\n"), 3)
  end

  test "show errors when creating an invalid report" do
    user_rec = users(:agent_1)

    post(auth("/reports", as: user_rec), params: {
      report: {
        report: "accounting",
        start_date: "2020-05-12",
        end_date: "2020-05-11",
      }
    })

    assert_response(:success)
    assert_equal(response.media_type, "text/html")
    assert_present(flash[:alert])
  end
end
