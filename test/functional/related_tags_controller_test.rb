require 'test_helper'

class RelatedTagsControllerTest < ActionDispatch::IntegrationTest
  context "The related tags controller" do
    setup do
      as(create(:user)) { create(:post, tag_string: "copy:touhou") }
    end

    context "show action" do
      should "work" do
        get related_tag_path, params: { query: "touhou" }
        assert_response :success
      end

      should "work for .json responses" do
        get related_tag_path(format: :json), params: { query: "touhou" }
        assert_response :success
      end

      should "work for .js responses for copyright tags without a wiki" do
        get related_tag_path(format: :js), params: { query: "touhou" }, xhr: true
        assert_response :success
      end

      should "work for .js responses for character tags without a wiki" do
        create(:tag, name: "chen", category: TagCategory::CHARACTER)

        get related_tag_path(format: :js), params: { query: "chen" }, xhr: true
        assert_response :success
      end

      should "work for .js responses for character tags with a wiki" do
        create(:tag, name: "chen", category: TagCategory::CHARACTER)
        create(:wiki_page, title: "chen", body: "[[touhou]]")

        get related_tag_path(format: :js), params: { query: "chen" }, xhr: true
        assert_response :success
      end
    end
  end
end
