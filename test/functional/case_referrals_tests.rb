require "test_helper"

class CaseReferralsTests < ActionDispatch::IntegrationTest
  test "can't make a referral if signed-out" do
    get("/cases/3/referrals/new")
    assert_redirected_to("/sign-in")
  end

  test "can't make a referral without permission" do
    user_rec = users(:supplier_1)

    get(auth("/cases/4/referrals/new", as: user_rec))
    assert_redirected_to("/cases")
  end

  test "make a referral as a cohere user" do
    user_rec = users(:cohere_1)
    case_rec = cases(:approved_1)

    get(auth("/cases/#{case_rec.id}/referrals/new", as: user_rec))
    assert_response(:success)
  end

  test "save a referral as a cohere user" do
    skip

    user_rec = users(:cohere_1)
    case_rec = cases(:approved_1)
    supplier_rec = partners(:supplier_3)

    post(auth("/cases/#{case_rec.id}/referrals", as: user_rec), params: {
      case: {
        supplier_account: {
          supplier_id: supplier_rec.id
        }
      }
    })

    assert_redirected_to(%r[/cases/\d+/edit])
    assert_present(flash[:notice])

    assert_send_emails(0)
    assert_analytics_events(2) do |events|
      assert_match(/Did Make Referral/, events[0])
      assert_match(/Did Open/, events[1])
    end
  end

  test "show errors when saving an invalid referral as a cohere user" do
    user_rec = users(:cohere_1)
    case_rec = cases(:approved_1)
    supplier_rec = partners(:supplier_3)

    post(auth("/cases/#{case_rec.id}/referrals", as: user_rec), params: {
      case: {
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
