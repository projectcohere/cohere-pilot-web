require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driver = ENV["SYSTEM_TEST_UI"].present? ? :chrome : :headless_chrome
  driven_by(:selenium, using: driver)
end
