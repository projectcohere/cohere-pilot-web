require "system_test_helper"

class CaseFlowTests < ApplicationSystemTestCase
  test "processing a new case and referrals" do
    # -- setup --
    set_working_hours!

    # -- source --
    visit(sign_in_url)

    # -- source -> sign in
    assert_current_path("/sign-in")

    fill_in("E-mail Field", with: "source@testmetro.org")
    fill_in("Password Field", with: "password123$")
    click_button("Sign In Button")

    # -- source -> list cases
    assert_current_path("/cases")

    click_button("New Case Button")

    # -- source -> pick program
    assert_current_path("/cases/select")

    select("Housing (CARES)", from: "Program Select")
    select("Food (CARES)", from: "Program Select")
    click_button("Select Program Button")

    # -- source -> add case
    assert_current_path(%r[/cases/new\?temp_id=\w+&case%5Bprogram_id%5D=\d+])
    assert_selector("h1", text: "Open a New Case")
    assert_selector("h1", text: "Food")

    fill_in("First Name Field", with: "Celine")
    fill_in("Last Name Field", with: "Sample")
    fill_in("Phone Number Field", with: "(888) 393-4401")

    fill_in("Street Field", with: "123 Test St.")
    fill_in("Street Two Field", with: "Apt. 4")
    fill_in("City Field", with: "Testopolis")
    fill_in("Zip Field", with: "40292")

    select("Active MDHHS Case", from: "Proof Of Income Field")
    check("Dietary Restrictions Field")

    click_button("Save Button")

    # -- source -> add case -> errors
    assert_current_path("/cases")
    assert_selector("h1", text: "Open a New Case")
    assert_selector(".Flash.is-alert", text: "Please check the case for errors.")

    check("Geography Field")
    VCR.use_cassette("chats--send-cohere-msg--attachments") do
      click_button("Save Button")
    end

    # -- source -> opened case
    assert_current_path("/cases")
    assert_selector(".Flash", text: "Created case!")

    find(".NavigationProfile").hover
    click_button("Sign Out Button")

    # -- agent --
    # -- agent -> sign in
    assert_current_path("/sign-in")
  end
end
