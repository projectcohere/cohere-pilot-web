require "test_helper"

class CasesTests < ActionDispatch::IntegrationTest
  include ActionCable::Channel::TestCase::Behavior

  # -- list --
  test "can't list cases if signed-out" do
    get("/cases")
    assert_redirected_to("/sign-in")
  end

  test "can list cases as a source" do
    user_rec = users(:source_1)

    get(auth("/cases", as: user_rec))
    assert_response(:success)
    assert_select(".PageHeader-title", text: /All Cases/)
    assert_select(".CaseCell", 1)
  end

  test "can list cases as an agent" do
    user_rec = users(:agent_1)

    get(auth("/cases", as: user_rec))
    assert_response(:success)

    get(auth("/cases?scope=all", as: user_rec))
    assert_response(:success)
    assert_select(".PageHeader-title", text: /All Cases/)
    assert_select(".CaseCell", 10)
  end

  test "can list cases with a search query as an agent" do
    user_rec = users(:agent_1)

    get(auth("/cases?scope=all&search=Janice", as: user_rec))
    assert_response(:success)
    assert_select(".CaseCell", 3)
  end

  test "can list open cases as an agent" do
    user_rec = users(:agent_1)

    get(auth("/cases?scope=open", as: user_rec))
    assert_response(:success)
    assert_select(".PageHeader-title", text: /Open Cases/)
    assert_select(".CaseCell", 8)
  end

  test "can list completed cases as an agent" do
    user_rec = users(:agent_1)

    get(auth("/cases?scope=completed", as: user_rec))
    assert_response(:success)
    assert_select(".PageHeader-title", text: /Completed Cases/)
    assert_select(".CaseCell", 2)
  end

  test "can list assigned cases as an agent" do
    user_rec = users(:agent_1)

    get(auth("/cases/queue", as: user_rec))
    assert_response(:success)

    get(auth("/cases/queue?scope=assigned", as: user_rec))
    assert_response(:success)
    assert_select(".PageHeader-title", text: /My Cases/)
    assert_select(".CaseCell", 1)
  end

  test "can list queued cases as an agent" do
    user_rec = users(:agent_1)

    get(auth("/cases/queue?scope=queued", as: user_rec))
    assert_response(:success)
    assert_select(".PageHeader-title", text: /Available Cases/)
    assert_select(".CaseCell", 7)
  end

  test "can list cases as a governor" do
    user_rec = users(:governor_1)

    get(auth("/cases", as: user_rec))
    assert_response(:success)
    assert_select(".PageHeader-title", text: /All Cases/)
    assert_select(".CaseCell", 5)
  end

  test "can list assigned cases as a governor" do
    user_rec = users(:governor_1)

    get(auth("/cases/queue", as: user_rec))
    assert_response(:success)

    get(auth("/cases/queue?scope=assigned", as: user_rec))
    assert_response(:success)
    assert_select(".PageHeader-title", text: /My Cases/)
    assert_select(".CaseCell", 1)
  end

  test "can list queued cases as a governor" do
    user_rec = users(:governor_1)

    get(auth("/cases/queue?scope=queued", as: user_rec))
    assert_response(:success)
    assert_select(".PageHeader-title", text: /Available Cases/)
    assert_select(".CaseCell", 4)
  end

  test "can list cases as an enroller" do
    user_rec = users(:enroller_1)

    get(auth("/cases", as: user_rec))
    assert_response(:success)
    assert_select(".PageHeader-title", text: /All Cases/)
    assert_select(".CaseCell", 3)
  end

  test "can list assigned cases as an enroller" do
    user_rec = users(:enroller_1)

    get(auth("/cases/queue", as: user_rec))
    assert_response(:success)

    get(auth("/cases/queue?scope=assigned", as: user_rec))
    assert_response(:success)
    assert_select(".PageHeader-title", text: /My Cases/)
    assert_select(".CaseCell", 1)
  end

  test "can list queued cases as an enroller" do
    user_rec = users(:enroller_1)

    get(auth("/cases/queue?scope=queued", as: user_rec))
    assert_response(:success)
    assert_select(".PageHeader-title", text: /Available Cases/)
    assert_select(".CaseCell", 0)
  end

  # -- create --
  test "can't select a case program if signed-out" do
    get("/cases/select")
    assert_redirected_to("/sign-in")
  end

  test "can't select a case program without permission" do
    user_rec = users(:enroller_1)

    get(auth("/cases/select", as: user_rec))
    assert_redirected_to("/cases/queue")
  end

  test "select a case program" do
    user_rec = users(:source_1)
    case_rec = cases(:approved_2)

    get(auth("/cases/select", as: user_rec))
    assert_response(:success)
  end

  test "can't view open case form if signed-out" do
    get("/cases/new?program_id=3")
    assert_redirected_to("/sign-in")
  end

  test "can't view open case form without permission" do
    user_rec = users(:agent_1)

    get(auth("/cases/new?program_id=3", as: user_rec))
    assert_redirected_to("/cases/queue")
  end

  test "views open case form as a source" do
    user_rec = users(:source_1)
    program_rec = user_rec.partner.programs.first

    get(auth("/cases/new?program_id=#{program_rec.id}", as: user_rec))
    assert_response(:success)
    assert_select(".PageHeader-title", text: /Add a Case/)

    assert_analytics_events(1) do |events|
      assert_match(/Did View Supplier Form/, events[0])
    end
  end

  test "views open case form as a non-supplier source" do
    user_rec = users(:source_3)
    program_rec = user_rec.partner.programs.first

    get(auth("/cases/new?program_id=#{program_rec.id}", as: user_rec))
    assert_response(:success)
    assert_select(".PageHeader-title", text: /Add a Case/)
  end

  test "opens a case as a source" do
    user_rec = users(:source_1)
    program_rec = user_rec.partner.programs.first

    case_params = {
      program_id: program_rec.id,
      contact: {
        first_name: "Janice",
        last_name: "Sample",
        phone_number: Faker::Number.number(digits: 10),
      },
      address: {
        street: "123 Test Street",
        city: "Testopolis",
        zip: "11111",
        geography: true,
      },
      household: {
        proof_of_income: "dhs",
      },
      supplier_account: {
        account_number: "22222",
        arrears: "1000.00"
      }
    }

    act = -> do
      VCR.use_cassette("chats--send-cohere-msg--attachments") do
        post(auth("/cases", as: user_rec), params: {
          case: case_params
        })
      end
    end

    assert_difference(
      -> { Case::Record.count } => 1,
      -> { Case::Assignment::Record.count } => 1,
      -> { Recipient::Record.count } => 1,
      -> { Chat::Record.count } => 1,
      -> { Chat::Message::Record.count } => 1,
      &act
    )

    assert_present(flash[:notice])
    assert_redirected_to("/cases")

    assert_analytics_events(1) do |events|
      assert_match(/Did Open/, events[0])
    end

    assert_matching_broadcast_on(case_activity_for(:agent_1)) do |msg|
      assert_equal(msg["name"], "DID_ADD_QUEUED_CASE")
      assert_entry(msg["data"], "case_id")
    end

    assert_matching_broadcast_on(case_activity_for(:governor_1)) do |msg|
      assert_equal(msg["name"], "DID_ADD_QUEUED_CASE")
      assert_entry(msg["data"], "case_id")
    end

    assert_send_emails(1) do
      assert_select("a", text: /Janice Sample/) do |el|
        assert_match(%r[#{ENV["HOST"]}/cases/\d+/edit], el[0][:href])
      end
    end
  end

  test "opens a case a non-supplier source" do
    user_rec = users(:source_3)
    program_rec = user_rec.partner.programs.find { |p| p.requirements.blank? }

    case_params = {
      program_id: program_rec.id,
      contact: {
        first_name: "Janice",
        last_name: "Sample",
        phone_number: Faker::Number.number(digits: 10),
      },
      address: {
        street: "123 Test Street",
        city: "Testopolis",
        zip: "11111",
        geography: true,
      },
      household: {
        proof_of_income: "dhs",
      },
      supplier_account: {
        account_number: "22222",
        arrears: "1000.00"
      }
    }

    act = -> do
      VCR.use_cassette("chats--send-cohere-msg--attachments") do
        post(auth("/cases", as: user_rec), params: {
          case: case_params
        })
      end
    end

    assert_difference(
      -> { Case::Record.count } => 1,
      -> { Case::Assignment::Record.count } => 1,
      -> { Recipient::Record.count } => 1,
      -> { Chat::Record.count } => 1,
      -> { Chat::Message::Record.count } => 1,
      &act
    )

    assert_present(flash[:notice])
    assert_redirected_to("/cases")
  end

  test "show errors when opening an invalid case as a source" do
    user_rec = users(:source_1)
    program_rec = user_rec.partner.programs.first

    post(auth("/cases", as: user_rec), params: {
      case: {
        program_id: program_rec.id,
        contact: {
          first_name: "Janice",
        },
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
    user_rec = users(:source_1)
    case_rec = cases(:submitted_1)

    get(auth("/cases/#{case_rec.id}", as: user_rec))
    assert_redirected_to("/cases")
  end

  test "can't view another enroller's case as an enroller" do
    user_rec = users(:enroller_1)
    case_rec = cases(:submitted_2)

    assert_raises(ActiveRecord::RecordNotFound) do
      get(auth("/cases/#{case_rec.id}", as: user_rec))
    end
  end

  test "view a case as an agent" do
    user_rec = users(:agent_1)
    case_rec = cases(:approved_1)
    kase = Case::Repo.map_record(case_rec)

    get(auth("/cases/#{kase.id}", as: user_rec))
    assert_response(:success)
    assert_select(".PageHeader-title", text: /#{kase.recipient.profile.name}/)
  end

  test "view a case as an enroller" do
    user_rec = users(:enroller_1)
    case_rec = cases(:submitted_1)
    kase = Case::Repo.map_record(case_rec)

    get(auth("/cases/#{kase.id}", as: user_rec))
    assert_response(:success)
    assert_select(".PageHeader-title", text: /#{kase.recipient.profile.name}/)

    assert_analytics_events(1) do |events|
      assert_match(/Did View Enroller Case/, events[0])
    end
  end

  # -- edit --
  test "can't edit a case if signed-out" do
    case_rec = cases(:submitted_1)

    get("/cases/#{case_rec.id}/edit")
    assert_redirected_to("/sign-in")
  end

  test "can't edit a case without permission" do
    user_rec = users(:source_1)
    case_rec = cases(:submitted_1)

    get(auth("/cases/#{case_rec.id}", as: user_rec))
    assert_redirected_to("/cases")
  end

  test "edit a case as a governor" do
    user_rec = users(:governor_1)
    case_rec = cases(:pending_1)

    get(auth("/cases/#{case_rec.id}/edit", as: user_rec))
    assert_response(:success)
    assert_select(".PageHeader-title", text: /\w's case/)

    assert_analytics_events(1) do |events|
      assert_match(/Did View Governor Form/, events[0])
    end
  end

  test "save an edited case as a governor" do
    user_rec = users(:governor_1)
    case_rec = cases(:opened_1)

    patch(auth("/cases/#{case_rec.id}", as: user_rec), params: {
      case: {
        household: {
          size: "5",
          income: "$500.00",
          dhs_number: "12345",
        },
      }
    })

    assert_redirected_to("/cases")
    assert_present(flash[:notice])

    assert_broadcast_on(case_activity_for(:agent_1), {
      name: "HAS_NEW_ACTIVITY",
      data: {
        case_id: case_rec.id,
        case_new_activity: true,
      }
    })

    assert_analytics_events(1) do |events|
      assert_match(/Did Become Pending/, events[0])
    end
  end

  test "edit a case as an agent" do
    user_rec = users(:agent_1)
    case_rec = cases(:submitted_1)

    get(auth("/cases/#{case_rec.id}/edit", as: user_rec))
    assert_response(:success)
    assert_select(".PageHeader-title", text: /\w+'s case/)
  end

  test "save an edited case as an agent" do
    case_rec = cases(:pending_1)

    patch(auth("/cases/#{case_rec.id}"), params: {
      case: {
        household: {
          income: "$300.00"
        },
        admin: {
          status: "submitted",
        },
      }
    })

    assert_equal(case_rec.reload.status, "submitted")

    assert_broadcast_on(case_activity_for(:agent_1), {
      name: "HAS_NEW_ACTIVITY",
      data: {
        case_id: case_rec.id,
        case_new_activity: false,
      }
    })

    assert_redirected_to("/cases/#{case_rec.id}/edit")
    assert_present(flash[:notice])
    assert_send_emails(0)
  end

  test "save a signed contract" do
    case_rec = cases(:pending_2)

    act = ->() do
      patch(auth("/cases/#{case_rec.id}"), params: {
        case: {
          details: {
            contract_variant: :meap
          }
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
    assert_match(/Janice\s*Sample/, pdf_text)
  end

  test "show errors when saving an invalid case as an agent" do
    case_rec = cases(:pending_1)

    patch(auth("/cases/#{case_rec.id}"), params: {
      case: {
        contact: {
          first_name: ""
        }
      }
    })

    assert_response(:success)
    assert_present(flash[:alert])
  end

  # -- edit/save --
  test "can't update a case with an action if signed-out" do
    assert_raises(ActionController::RoutingError) do
      patch("/cases/3", params: {
        approve: :ignored
      })
    end
  end

  test "can't update a case with an action without permission" do
    user_rec = users(:source_1)

    assert_raises(ActionController::RoutingError) do
      patch(auth("/cases/4", as: user_rec), params: {
        deny: :ignored
      })
    end
  end

  test "show errors submitting an invalid case as an agent" do
    case_rec = cases(:pending_2)

    patch(auth("/cases/#{case_rec.id}"), params: {
      submit: :ignored
    })

    assert_response(:success)
    assert_present(flash[:alert])
  end

  test "submit a case as an agent" do
    user_rec = users(:agent_1)
    case_rec = cases(:pending_1)

    patch(auth("/cases/#{case_rec.id}", as: user_rec), params: {
      submit: :ignored
    })

    assert_redirected_to("/cases/#{case_rec.id}/edit")
    assert_present(flash[:notice])

    assert_broadcast_on(case_activity_for(:agent_1), {
      name: "HAS_NEW_ACTIVITY",
      data: {
        case_id: case_rec.id,
        case_new_activity: false,
      }
    })

    # TODO: not sure why, but this assert is flaky
    # assert_matching_broadcast_on(case_activity_for(:enroller_1)) do |msg|
    #   assert_equal(msg["name"], "DID_ADD_QUEUED_CASE")
    #   assert_entry(msg["data"], "case_id")
    # end

    assert_analytics_events(1) do |events|
      assert_match(/Did Submit/, events[0])
    end

    assert_send_emails(1) do
      assert_select("a", text: /Johnice Sample/) do |el|
        assert_match(%r[#{ENV["HOST"]}/cases/\d+], el[0][:href])
      end
    end
  end

  # -- destroy --
  test "can't destroy a case if signed-out" do
    assert_raises(ActionController::RoutingError) do
      delete("/cases/3")
    end
  end

  test "can't destroy a case without permission" do
    user_rec = users(:source_1)

    assert_raises(ActionController::RoutingError) do
      delete(auth("/cases/4", as: user_rec))
    end
  end

  test "destroy a case" do
    user_rec = users(:agent_1)
    case_rec = cases(:pending_1)

    delete(auth("/cases/#{case_rec.id}", as: user_rec))

    assert_redirected_to("/cases")
    assert_present(flash[:notice])
  end

  # -- complete --
  test "can't complete a case with an unknown status as an enroller" do
    user_rec = users(:enroller_1)

    assert_raises(ActionController::RoutingError) do
      patch(auth("/cases/0/remove", as: user_rec))
    end
  end

  test "can't complete another enroller's case as an enroller" do
    user_rec = users(:enroller_1)
    case_rec = cases(:submitted_2)

    assert_raises(ActiveRecord::RecordNotFound) do
      patch(auth("/cases/#{case_rec.id}/approve", as: user_rec), params: {
        deny: :ignored
      })
    end
  end

  test "complete a case as an enroller" do
    user_rec = users(:enroller_1)
    case_rec = cases(:submitted_1)

    patch(auth("/cases/#{case_rec.id}/deny", as: user_rec))
    assert_redirected_to("/cases/#{case_rec.id}")
    assert_present(flash[:notice])

    assert_broadcast_on(case_activity_for(:agent_1), {
      name: "HAS_NEW_ACTIVITY",
      data: {
        case_id: case_rec.id,
        case_new_activity: false,
      }
    })

    assert_analytics_events(1) do |events|
      assert_match(/Did Complete/, events[0])
    end

    assert_send_emails(1) do
      assert_select("a", text: /Johnice Sample/) do |el|
        assert_match(%r[#{ENV["HOST"]}/cases/\d+], el[0][:href])
      end

      assert_select("p", text: /denied/)
    end
  end

  test "complete a case as an agent" do
    user_rec = users(:agent_1)
    case_rec = cases(:submitted_1)

    patch(auth("/cases/#{case_rec.id}", as: user_rec), params: {
      approve: :ignored
    })

    assert_redirected_to("/cases/#{case_rec.id}")
    assert_present(flash[:notice])

    assert_broadcast_on(case_activity_for(:agent_1), {
      name: "HAS_NEW_ACTIVITY",
      data: {
        case_id: case_rec.id,
        case_new_activity: false,
      }
    })

    assert_analytics_events(1) do |events|
      assert_match(/Did Complete/, events[0])
    end

    assert_send_emails(1) do
      assert_select("a", text: /Johnice Sample/) do |el|
        assert_match(%r[#{ENV["HOST"]}/cases/\d+], el[0][:href])
      end

      assert_select("p", text: /approved/)
    end
  end

  test "remove a case from the pilot as an agent" do
    user_rec = users(:agent_1)
    case_rec = cases(:pending_1)

    patch(auth("/cases/#{case_rec.id}", as: user_rec), params: {
      remove: :ignored
    })

    assert_redirected_to("/cases/#{case_rec.id}")
    assert_present(flash[:notice])

    assert_broadcast_on(case_activity_for(:agent_1), {
      name: "HAS_NEW_ACTIVITY",
      data: {
        case_id: case_rec.id,
        case_new_activity: false,
      }
    })

    assert_analytics_events(1) do |events|
      assert_match(/Did Complete/, events[0])
    end

    assert_send_emails(0)
  end
end
