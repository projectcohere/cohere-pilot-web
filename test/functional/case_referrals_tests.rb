require "test_helper"

class CaseReferralsTests < ActionDispatch::IntegrationTest
  test "can't select a referral program if signed-out" do
    get("/cases/3/referrals/select")
    assert_redirected_to("/sign-in")
  end

  test "can't select a referral program without permission" do
    user_rec = users(:source_1)

    get(auth("/cases/4/referrals/select", as: user_rec))
    assert_redirected_to("/cases")
  end

  test "select a referral program" do
    user_rec = users(:agent_1)
    case_rec = cases(:approved_2)

    get(auth("/cases/#{case_rec.id}/referrals/select", as: user_rec))
    assert_response(:success)
  end

  test "can't start a referral if signed-out" do
    get("/cases/3/referrals/new?case[program_id]=6")
    assert_redirected_to("/sign-in")
  end

  test "can't start a referral without permission" do
    user_rec = users(:source_1)

    get(auth("/cases/4/referrals/new?case[program_id]=6", as: user_rec))
    assert_redirected_to("/cases")
  end

  test "can't start a referral without a program" do
    user_rec = users(:agent_1)
    case_rec = cases(:approved_2)

    get(auth("/cases/#{case_rec.id}/referrals/new?case[program_id]=", as: user_rec))
    assert_redirected_to("/cases/#{case_rec.id}")
  end

  test "start a referral as an agent" do
    user_rec = users(:agent_1)
    case_rec = cases(:approved_2)
    program_rec = programs(:water_0)

    get(auth("/cases/#{case_rec.id}/referrals/new?case[program_id]=#{program_rec.id}", as: user_rec))
    assert_response(:success)
  end

  test "save a referral as an agent" do
    user_rec = users(:agent_1)
    case_rec = cases(:approved_1)
    program_rec = programs(:water_0)
    supplier_rec = partners(:supplier_3)

    post(auth("/cases/#{case_rec.id}/referrals", as: user_rec), params: {
      case: {
        program_id: program_rec.id,
        household: {
          ownership: Recipient::Ownership::Rent.key,
        },
        supplier_account: {
          supplier_id: supplier_rec.id
        },
      }
    })

    assert_redirected_to(%r[/cases/\d+/edit])
    assert_present(flash[:notice])

    assert_analytics_events(%w[
      DidMakeReferral
      DidOpen
    ])
  end

  test "show errors when saving an invalid referral as an agent" do
    user_rec = users(:agent_1)
    case_rec = cases(:approved_1)
    program_rec = programs(:water_0)
    supplier_rec = partners(:supplier_3)

    post(auth("/cases/#{case_rec.id}/referrals", as: user_rec), params: {
      case: {
        program_id: program_rec.id,
        contact: {
          first_name: ""
        },
        supplier_account: {
          supplier_id: supplier_rec.id,
        }
      }
    })

    assert_response(:success)
    assert_present(flash[:alert])
  end
end
