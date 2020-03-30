require "test_helper"

class DtextLinksControllerTest < ActionDispatch::IntegrationTest
  context "index action" do
    should "work" do
      @user = create(:user)
      @wiki = as(@user) { create(:wiki_page, body: "[[test]]") }
      get dtext_links_path
      assert_response :success
    end
  end
end
