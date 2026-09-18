require "application_system_test_case"

class SidebarTest < ApplicationSystemTestCase
  context "The sidebar" do
    should "let a user pin it to the right and persist the choice" do
      visit posts_path

      find("aside#sidebar .popup-menu-button").click
      click_link "Pin to Right"

      assert_selector "aside#sidebar[data-dock='right']"
      assert_equal "right", page.driver.browser.manage.cookie_named("sidebar_dock")[:value].delete('"')
    end
  end
end
