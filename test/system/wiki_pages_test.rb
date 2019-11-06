require "application_system_test_case"

class WikiPagesTest < ApplicationSystemTestCase
  context "renaming a wiki" do
    should "work" do
      @user = create(:user, level: User::Levels::BUILDER, created_at: 1.month.ago)
      @wiki = as(@user) { create(:wiki_page, title: "kancolle") }

      signin @user
      visit wiki_page_path(@wiki)
      click_on "Edit"
      fill_in "Title", with: "kantai_collection"
      click_on "Submit"

      assert_selector "#wiki-page-title", text: "kantai collection"
      assert_equal("kantai_collection", @wiki.reload.title)
    end
  end
end
