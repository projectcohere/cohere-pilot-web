require "system_test_helper"

class CaseFlowTests < ApplicationSystemTestCase
  test "processing a new case and referrals" do
    visit(sign_in_url)
    assert_selector("h1", text: "Welcome to Cohere!")
  end
end
