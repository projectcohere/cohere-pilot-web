require "system_test_helper"

class CaseFlowTests < ApplicationSystemTestCase
  # -- tests --
  test "processes a new case" do
    # TODO: we need a more reliable way to find the "right" enroller than
    # PartnerRepo#find_default_enroller
    partners(:enroller_2).supplier!

    # -- setup --
    set_working_hours!
    visit("/")

    # ------------
    # -- source --
    # ------------

    # source -> sign in
    assert_current_path("/sign-in")

    fill_in("E-mail Field", with: "source@testmetro.org")
    fill_in("Password Field", with: "password123$")
    click_button("Sign In Button")

    # source -> list cases
    assert_current_path("/cases")

    click_button("New Case Button")

    # source -> pick program
    assert_current_path("/cases/select")

    select("Housing (CARES)", from: "Program Select")
    select("Food (CARES)", from: "Program Select")
    click_button("Select Program Button")

    # source -> add case
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
    check("Dietary Restrictions Field")
    select("Active MDHHS Case", from: "Proof Of Income Field")
    click_button("Save Button")

    # source -> add case -> errors
    assert_current_path("/cases")
    assert_selector("h1", text: "Open a New Case")
    assert_selector(".Flash.is-alert", text: "Please check the case for errors.")

    check("Geography Field")
    VCR.use_cassette("chats--send-cohere-msg--attachments") do
      click_button("Save Button")
    end

    # source -> opened case
    assert_current_path("/cases")
    assert_selector(".Flash", text: "Created case!")

    find(".NavigationProfile").hover
    click_button("Sign Out Button")

    # -----------
    # -- agent --
    # -----------

    # agent -> sign in
    assert_current_path("/sign-in")

    fill_in("E-mail Field", with: "me@projectcohere.com")
    fill_in("Password Field", with: "password123$")
    click_button("Sign In Button")

    # agent -> list cases
    assert_current_path("/cases")

    click_link("Inbox Page Link")

    # agent -> inbox
    assert_current_path("/cases/inbox")

    find_cell("Celine Sample").click_button("Case Cell Assign Button")

    # agent -> inbox -> assigned
    assert_current_path("/cases/inbox")
    assert_selector(".Flash", text: "You've been assigned to Celine Sample's case.")

    click_link("Your Cases Link")

    # agent -> list cases
    assert_current_path("/cases")

    click_link("Case Cell Link", text: "Celine Sample")

    # agent -> edit case
    assert_current_path(%r[/cases/\d+/edit])
    assert_selector("h1", text: "Celine Sample's case")

    click_link("Household Filter")
    fill_in("Household Size Field", with: "3")
    fill_in("Household Income Field", with: "1234.0")
    fill_in("Dhs Number Field", with: "1234")

    click_link("Program Filter")
    check("Dietary Restrictions Field")

    click_button("Save Button")

    # agent -> edit case -> saved
    assert_current_path(%r[/cases/\d+/edit])
    assert_selector("h1", text: "Celine Sample's case")
    assert_selector(".Flash", text: "Updated Celine Sample's case.")

    # agent -> edit case -> chat
    find("#chat-input").set("Hello, it's Gaby.")
    click_button("Chat Send Message Button")

    assert_selector(".ChatMessage-body", text: "Hello, it's Gaby.")

    # agent -> submit case
    assert_current_path(%r[/cases/\d+/edit])

    accept_alert do
      click_button("Save & Submit Button")
    end

    # agent -> submit case -> errors
    assert_current_path(%r[/cases/\d+])
    assert_selector("h1", text: "Celine Sample's case")
    assert_selector(".Flash.is-alert", text: "Please check Celine Sample's case for errors.")

    # TODO: HMW simulate an inbound message with a document (alternatively, use the "Upload
    # Document" feature when that's built)
    case_rec = Case::Record.with_phone_number("8883934401").first!
    case_rec.documents.create

    accept_alert do
      click_button("Save & Submit Button")
    end

    # agent -> submitted
    assert_current_path("/cases")
    assert_selector(".Flash", text: "Submitted Celine Sample's case.")

    find(".NavigationProfile").hover
    click_button("Sign Out Button")

    # --------------
    # -- enroller --
    # --------------

    # enroller -> sign in
    assert_current_path("/sign-in")

    fill_in("E-mail Field", with: "enroll@testmetro.org")
    fill_in("Password Field", with: "password123$")
    click_button("Sign In Button")

    # enroller -> list cases
    assert_current_path("/cases")

    click_link("Inbox Page Link")

    # enroller -> inbox
    assert_current_path("/cases/inbox")

    find_cell("Celine Sample").click_button("Case Cell Assign Button")

    # enroller -> inbox -> assigned
    assert_current_path("/cases/inbox")
    assert_selector(".Flash", text: "You've been assigned to Celine Sample's case.")

    click_link("Your Cases Link")

    # enroller -> list cases
    assert_current_path("/cases")

    click_link("Case Cell Link", text: "Celine Sample")

    # enroller -> edit case
    assert_current_path(%r[/cases/\d+/edit])
    assert_selector("h1", text: "Celine Sample's case")

    accept_alert do
      click_button("Save & Approve Button")
    end

    # enroller -> complete case -> errors
    assert_current_path(%r[/cases/\d+])
    assert_selector("h1", text: "Celine Sample's case")
    assert_selector(".Flash.is-alert", text: "Please check Celine Sample's case for errors.")

    fill_in("Benefit Amount Field", with: "144.0")
    accept_alert do
      click_button("Save & Approve Button")
    end

    # enroller -> complete case
    assert_current_path("/cases")
    assert_selector(".Flash", text: "Approved Celine Sample's case.")
  end

  # -- helpers --
  def find_cell(name)
    return find(".CaseCell-name", text: name).ancestor(".CaseCell")
  end
end
