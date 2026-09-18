require "application_system_test_case"

module PaginatorTestMethods
  extend ActiveSupport::Concern

  included do
    setup { create_list(:post, 25) } # rubocop:disable FactoryBot/ExcessiveCreateList
  end

  def visit_page(page)
    visit posts_path(page: page, limit: 1)
  end
end

class PaginatorChromeTest < ChromeSystemTestCase
  include PaginatorTestMethods

  context "The numbered paginator on desktop" do
    should "show the full range of page links" do
      visit_page(10)

      assert_visible ".paginator-page", minimum: 2
      assert_visible "span.paginator-current", text: "10"
    end

    should "hide the mobile-only ellipsis" do
      visit_page(3)

      assert_hidden ".paginator-ellipsis.mobile-only"
    end
  end
end

class PaginatorMobileChromeTest < MobileChromeSystemTestCase
  include PaginatorTestMethods

  context "The numbered paginator on mobile" do
    should "only show the first, current, and last pages, with ellipses in between" do
      visit_page(10)

      assert_hidden ".paginator-page.desktop-only"
      assert_visible ".paginator-page", count: 2 # the first and last page links
      assert_selector ".paginator-ellipsis", count: 2
      assert_visible "span.paginator-current", text: "10"
    end

    should "not show a leading ellipsis on the first page" do
      visit_page(1)

      assert_selector ".paginator-ellipsis", count: 1
      assert_visible "span.paginator-current", text: "1"
    end

    should "not show a trailing ellipsis on the last page" do
      visit_page(25)

      assert_selector ".paginator-ellipsis", count: 1
      assert_visible "span.paginator-current", text: "25"
    end

    should "show a leading ellipsis on page 3" do
      visit_page(3)

      assert_visible ".paginator-page[href*='page=1']"
      assert_selector ".paginator-ellipsis.mobile-only", count: 1
      assert_visible "span.paginator-current", text: "3"
    end

    should "show a trailing ellipsis on third-to-last page" do
      visit_page(23)

      assert_visible ".paginator-page[href*='page=25']"
      assert_selector ".paginator-ellipsis.mobile-only", count: 1
      assert_visible "span.paginator-current", text: "23"
    end
  end
end
