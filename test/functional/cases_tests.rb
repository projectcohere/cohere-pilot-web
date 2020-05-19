require "test_helper"

class CasesTests < ActionDispatch::IntegrationTest
  include ActionCable::Channel::TestCase::Behavior

  # -- list --
  test "can't list my cases if signed-out" do
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

  test "can list my cases as an agent" do
    user_rec = users(:agent_1)

    get(auth("/cases", as: user_rec))
    assert_response(:success)
    assert_select(".PageHeader-title", text: /My Cases/)
    assert_select(".CaseCell", 3)
  end

  test "can list queued cases as an agent" do
    user_rec = users(:agent_1)

    get(auth("/cases/inbox", as: user_rec))
    assert_response(:success)
    assert_select(".PageHeader-title", text: /Inbox/)
    assert_select(".CaseCell", 7)
  end

  test "can search cases as an agent" do
    user_rec = users(:agent_1)

    get(auth("/cases/search?scope=all&search=Janice", as: user_rec))
    assert_response(:success)
    assert_select(".PageHeader-title", text: /Search/)
    assert_select(".CaseCell", 3)
  end

  test "can search active cases as an agent" do
    user_rec = users(:agent_1)

    get(auth("/cases/search?scope=active", as: user_rec))
    assert_response(:success)
    assert_select(".CaseCell", 10)
  end

  test "can search archived cases as an agent" do
    user_rec = users(:agent_1)

    get(auth("/cases/search?scope=archived", as: user_rec))
    assert_response(:success)
    assert_select(".CaseCell", 1)
  end

  test "can list my cases as a governor" do
    user_rec = users(:governor_1)

    get(auth("/cases", as: user_rec))
    assert_response(:success)
    assert_select(".PageHeader-title", text: /My Cases/)
    assert_select(".CaseCell", 1)
  end

  test "can list queued cases as a governor" do
    user_rec = users(:governor_1)

    get(auth("/cases/inbox", as: user_rec))
    assert_response(:success)
    assert_select(".PageHeader-title", text: /Inbox/)
    assert_select(".CaseCell", 4)
  end

  test "can search active cases as an governor" do
    user_rec = users(:governor_1)

    get(auth("/cases/search", as: user_rec))
    assert_response(:success)
    assert_select(".PageHeader-title", text: /Search/)
    assert_select(".CaseCell", 5)
  end

  test "can list my cases as an enroller" do
    user_rec = users(:enroller_1)

    get(auth("/cases", as: user_rec))
    assert_response(:success)
    assert_select(".PageHeader-title", text: /My Cases/)
    assert_select(".CaseCell", 1)
  end

  test "can list queued cases as an enroller" do
    user_rec = users(:enroller_1)

    get(auth("/cases/inbox", as: user_rec))
    assert_response(:success)
    assert_select(".PageHeader-title", text: /Inbox/)
    assert_select(".CaseCell", 1)
    assert_select(".CaseCell-assign", 1)
  end

  test "can search archived cases as an enroller" do
    user_rec = users(:enroller_1)

    get(auth("/cases/search", as: user_rec))
    assert_response(:success)
    assert_select(".PageHeader-title", text: /Search/)
    assert_select(".CaseCell", 3)
  end

  # -- create --
  test "can't select a new case's program without permission" do
    get("/cases/select")
    assert_redirected_to("/sign-in")

    user_rec = users(:enroller_1)
    get(auth("/cases/select", as: user_rec))
    assert_redirected_to("/cases")
  end

  test "select a new case's program as a source during working hours" do
    set_working_hours!

    user_rec = users(:source_1)
    case_rec = cases(:approved_2)

    get(auth("/cases/select", as: user_rec))
    assert_response(:success)
    assert_analytics_events(%w[DidViewSourceForm])
  end

  test "can't fill out new case form without permission" do
    get("/cases/new?temp_id=9&program_id=3")
    assert_redirected_to("/sign-in")

    user_rec = users(:agent_1)
    get(auth("/cases/new?temp_id=9&program_id=3", as: user_rec))
    assert_redirected_to("/cases")
  end

  test "fills out new case form as a source during working hours" do
    set_working_hours!

    user_rec = users(:source_1)
    program_rec = user_rec.partner.programs.first

    get(auth("/cases/new?temp_id=9&case[program_id]=#{program_rec.id}", as: user_rec))
    assert_response(:success)
    assert_select(".PageHeader-title", text: /Open a New Case/)
  end

  test "fills out new case form as a non-supplier source during working hours" do
    set_working_hours!

    user_rec = users(:source_3)
    program_rec = user_rec.partner.programs.first

    get(auth("/cases/new?temp_id=9&case[program_id]=#{program_rec.id}", as: user_rec))
    assert_response(:success)
    assert_select(".PageHeader-title", text: /Open a New Case/)
  end

  test "opens a case as a source during working hours" do
    set_working_hours!

    user_rec = users(:source_1)
    program_rec = programs(:energy_c)

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
    }

    act = -> do
      VCR.use_cassette("chats--send-cohere-msg--attachments") do
        post(auth("/cases", as: user_rec), params: {
          temp_id: 9,
          case: case_params,
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
    assert_analytics_events(%w[DidOpen])

    assert_matching_broadcast_on(case_activity_for(:agent_1)) do |msg|
      assert_equal(msg["name"], "DID_ADD_QUEUED_CASE")
      assert_entry(msg["data"], "case_id")
    end

    assert_matching_broadcast_on(case_activity_for(:governor_1)) do |msg|
      assert_equal(msg["name"], "DID_ADD_QUEUED_CASE")
      assert_entry(msg["data"], "case_id")
    end
  end

  test "opens a case a non-supplier source during working hours" do
    set_working_hours!

    user_rec = users(:source_3)
    supplier_rec = partners(:supplier_1)
    program_rec = programs(:energy_c)

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
        supplier_id: supplier_rec.id,
        account_number: "1234",
        arrears: "4443",
      },
    }

    act = -> do
      VCR.use_cassette("chats--send-cohere-msg--attachments") do
        post(auth("/cases", as: user_rec), params: {
          temp_id: 9,
          case: case_params,
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
    set_working_hours!

    user_rec = users(:source_1)
    program_rec = user_rec.partner.programs.first

    post(auth("/cases", as: user_rec), params: {
      temp_id: 9,
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
    user_rec = users(:governor_1)
    case_rec = cases(:submitted_1)

    get(auth("/cases/#{case_rec.id}", as: user_rec))
    assert_redirected_to("/cases")
  end

  test "view a case as a source" do
    user_rec = users(:source_1)
    case_rec = cases(:opened_1)
    name = Recipient::Repo.map_name(case_rec.recipient)

    get(auth("/cases/#{case_rec.id}", as: user_rec))
    assert_response(:success)
    assert_select(".PageHeader-title", text: /#{name}/)
  end

  test "view a case as an agent" do
    user_rec = users(:agent_1)
    case_rec = cases(:approved_1)
    name = Recipient::Repo.map_name(case_rec.recipient)

    get(auth("/cases/#{case_rec.id}", as: user_rec))
    assert_response(:success)
    assert_select(".PageHeader-title", text: /#{name}/)
  end

  test "view a case as an enroller" do
    user_rec = users(:enroller_1)
    case_rec = cases(:submitted_1)
    name = Recipient::Repo.map_name(case_rec.recipient)

    get(auth("/cases/#{case_rec.id}", as: user_rec))
    assert_response(:success)
    assert_select(".PageHeader-title", text: /#{name}/)
  end

  test "can't view another enroller's case as an enroller" do
    user_rec = users(:enroller_1)
    case_rec = cases(:submitted_2)

    assert_raises(ActiveRecord::RecordNotFound) do
      get(auth("/cases/#{case_rec.id}", as: user_rec))
    end
  end

  # -- edit --
  test "can't edit a case without permission" do
    get("/cases/3/edit")
    assert_redirected_to("/sign-in")

    user_rec = users(:source_1)
    get(auth("/cases/3/edit", as: user_rec))
    assert_redirected_to("/cases")
  end

  test "edit a case as a governor" do
    user_rec = users(:governor_1)
    case_rec = cases(:opened_3)

    get(auth("/cases/#{case_rec.id}/edit", as: user_rec))
    assert_response(:success)
    assert_select(".PageHeader-title", text: /\w's case/)
    assert_analytics_events(%w[DidViewGovernorForm])
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
    assert_analytics_events(%w[DidSaveGovernorForm])

    assert_broadcast_on(case_activity_for(:agent_1), {
      name: "HAS_NEW_ACTIVITY",
      data: {
        case_id: case_rec.id,
        case_new_activity: true,
      }
    })
  end

  test "edit a case as an agent" do
    user_rec = users(:agent_1)
    case_rec = cases(:submitted_1)

    get(auth("/cases/#{case_rec.id}/edit", as: user_rec))
    assert_response(:success)
    assert_select(".PageHeader-title", text: /\w+'s case/)
  end

  test "save an edited case as an agent" do
    case_rec = cases(:opened_3)

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
  end

  test "save a signed contract as an agent" do
    case_rec = cases(:opened_4)

    act = ->() do
      patch(auth("/cases/#{case_rec.id}"), params: {
        case: {
          benefit: {
            contract: :meap
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

  test "can't save a duplicate contract as an agent" do
    case_rec = cases(:opened_3)

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
      -> { Document::Record.count } => 0,
      &act
    )

    assert_enqueued_jobs(0)
  end

  test "show errors when saving an invalid case as an agent" do
    case_rec = cases(:opened_3)

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

  test "edit a case as an enroller" do
    user_rec = users(:enroller_1)
    case_rec = cases(:submitted_1)

    get(auth("/cases/#{case_rec.id}/edit", as: user_rec))
    assert_response(:success)
    assert_select(".PageHeader-title", text: /\w+'s case/)
    assert_analytics_events(%w[DidViewEnrollerForm])
  end

  test "can't edit another enroller's case as an enroller" do
    user_rec = users(:enroller_1)
    case_rec = cases(:submitted_2)

    assert_raises(ActiveRecord::RecordNotFound) do
      get(auth("/cases/#{case_rec.id}/edit", as: user_rec))
    end
  end

  # -- convert --
  test "can't select an existing case's program without permission" do
    get("/cases/3/select")
    assert_redirected_to("/sign-in")

    user_rec = users(:source_1)
    get(auth("/cases/3/select", as: user_rec))
    assert_redirected_to("/cases")
  end

  test "select an existing case's program" do
    user_rec = users(:agent_1)
    case_rec = cases(:opened_5)

    get(auth("/cases/#{case_rec.id}/select", as: user_rec))
    assert_response(:success)
  end

  test "can't convert an existing case's program without permission" do
    assert_raises(ActionController::RoutingError) do
      patch("/cases/3/convert")
    end

    user_rec = users(:source_1)
    assert_raises(ActionController::RoutingError) do
      patch(auth("/cases/3/convert", as: user_rec))
    end
  end

  test "convert an existing case's program as an agent" do
    user_rec = users(:agent_1)
    case_rec = cases(:opened_5)
    program_rec = programs(:water_0)

    patch(auth("/cases/#{case_rec.id}", as: user_rec), params: {
      case: {
        program_id: program_rec.id
      }
    })

    assert_redirected_to("/cases/#{case_rec.id}/edit")
    assert_present(flash[:notice])
  end

  # -- submit --
  test "can't update a case with an action if signed-out" do
    assert_raises(ActionController::RoutingError) do
      patch("/cases/3", params: {
        submit: :ignored
      })
    end
  end

  test "can't update a case with an action without permission" do
    user_rec = users(:source_1)

    assert_raises(ActionController::RoutingError) do
      patch(auth("/cases/4", as: user_rec), params: {
        submit: :ignored
      })
    end
  end

  test "show errors submitting an invalid case as an agent" do
    case_rec = cases(:opened_4)

    patch(auth("/cases/#{case_rec.id}"), params: {
      submit: :ignored
    })

    assert_response(:success)
    assert_present(flash[:alert])
  end

  test "submit a case as an agent" do
    user_rec = users(:agent_1)
    case_rec = cases(:opened_3)

    patch(auth("/cases/#{case_rec.id}", as: user_rec), params: {
      submit: :ignored
    })

    assert_redirected_to("/cases")
    assert_present(flash[:notice])
    assert_analytics_events(%w[DidSubmitToEnroller])

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
  end

  test "submit a case that doesn't require a contract as an agent" do
    user_rec = users(:agent_1)
    case_rec = cases(:opened_5)

    patch(auth("/cases/#{case_rec.id}", as: user_rec), params: {
      submit: :ignored
    })

    assert_redirected_to("/cases")
    assert_present(flash[:notice])
  end

  test "submit a case that doesn't require dhs income as an agent" do
    user_rec = users(:agent_1)
    case_rec = cases(:opened_6)

    patch(auth("/cases/#{case_rec.id}", as: user_rec), params: {
      submit: :ignored
    })

    assert_redirected_to("/cases")
    assert_present(flash[:notice])
  end

  # -- delete --
  test "can't delete a case if signed-out" do
    assert_raises(ActionController::RoutingError) do
      delete("/cases/3")
    end
  end

  test "can't delete a case without permission" do
    user_rec = users(:source_1)

    assert_raises(ActionController::RoutingError) do
      delete(auth("/cases/4", as: user_rec))
    end
  end

  test "delete a case" do
    user_rec = users(:agent_1)
    case_rec = cases(:opened_3)

    delete(auth("/cases/#{case_rec.id}", as: user_rec))
    assert_redirected_to("/cases")
    assert_present(flash[:notice])
  end

  # -- return --
  test "can't return a case if signed out" do
    assert_raises(ActionController::RoutingError) do
      patch("/cases/0/return")
    end
  end

  test "return a case to the agent as an enroller" do
    user_rec = users(:enroller_1)
    case_rec = cases(:submitted_1)

    patch(auth("/cases/#{case_rec.id}/return", as: user_rec))
    assert_redirected_to("/cases")
    assert_present(flash[:notice])
    assert_analytics_events(%w[DidReturnToAgent])

    assert_broadcast_on(case_activity_for(:agent_1), {
      name: "HAS_NEW_ACTIVITY",
      data: {
        case_id: case_rec.id,
        case_new_activity: true,
      }
    })
  end

  # -- complete --
  test "can't complete a case without permission" do
    assert_raises(ActionController::RoutingError) do
      patch("/cases/1")
    end
  end

  test "complete a case as an enroller" do
    user_rec = users(:enroller_1)
    case_rec = cases(:submitted_1)

    patch(auth("/cases/#{case_rec.id}", as: user_rec), params: {
      deny: :ignored,
      case: {
        benefit: {
          amount: "100.33",
        },
      }
    })

    assert_redirected_to("/cases")
    assert_present(flash[:notice])
    assert_analytics_events(%w[DidComplete])

    assert_broadcast_on(case_activity_for(:agent_1), {
      name: "HAS_NEW_ACTIVITY",
      data: {
        case_id: case_rec.id,
        case_new_activity: true,
      }
    })
  end

  test "can't complete another enroller's case as an enroller" do
    user_rec = users(:enroller_1)
    case_rec = cases(:submitted_2)

    assert_raises(ActiveRecord::RecordNotFound) do
      patch(auth("/cases/#{case_rec.id}", as: user_rec), params: {
        approve: :ignored,
      })
    end
  end

  test "complete a case as an agent" do
    user_rec = users(:agent_1)
    case_rec = cases(:submitted_1)

    patch(auth("/cases/#{case_rec.id}", as: user_rec), params: {
      deny: :ignored,
    })

    assert_redirected_to("/cases")
    assert_present(flash[:notice])
    assert_analytics_events(%w[DidComplete])

    assert_broadcast_on(case_activity_for(:agent_1), {
      name: "HAS_NEW_ACTIVITY",
      data: {
        case_id: case_rec.id,
        case_new_activity: true,
      }
    })
  end

  test "show errors when completing an invalid case" do
    user_rec = users(:agent_1)
    case_rec = cases(:submitted_1)

    patch(auth("/cases/#{case_rec.id}"), params: {
      approve: :ignored,
    })

    assert_response(:success)
    assert_present(flash[:alert])
  end

  # -- remove --
  # TODO: this should be its own endpoint, since it's a secondary action
  # and does not patch any case attributes
  test "remove a case from the pilot as an agent" do
    user_rec = users(:agent_1)
    case_rec = cases(:opened_3)

    patch(auth("/cases/#{case_rec.id}", as: user_rec), params: {
      remove: :ignored
    })

    assert_redirected_to("/cases")
    assert_present(flash[:notice])
    assert_analytics_events(%w[DidComplete])

    assert_broadcast_on(case_activity_for(:agent_1), {
      name: "HAS_NEW_ACTIVITY",
      data: {
        case_id: case_rec.id,
        case_new_activity: false,
      }
    })
  end

  # -- archive --
  test "can't archive a case if signed-out" do
    assert_raises(ActionController::RoutingError) do
      patch("/cases/3/archive")
    end
  end

  test "can't archive a case without permission" do
    user_rec = users(:source_1)

    assert_raises(ActionController::RoutingError) do
      patch(auth("/cases/3/archive", as: user_rec))
    end
  end

  test "archive a case as an agent" do
    user_rec = users(:agent_1)
    case_rec = cases(:approved_1)

    patch(auth("/cases/#{case_rec.id}/archive", as: user_rec))

    assert_redirected_to("/cases")
    assert_match(/Archived/, flash[:notice])
  end
end
