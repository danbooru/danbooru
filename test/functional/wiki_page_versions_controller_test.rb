require 'test_helper'

class WikiPageVersionsControllerTest < ActionDispatch::IntegrationTest
  context "The wiki page versions controller" do
    setup do
      @user = create(:user)
      as_user do
        @wiki_page = create(:wiki_page)
        @wiki_page.update(:body => "1 2")
        @wiki_page.update(:body => "2 3")
      end
    end

    context "index action" do
      should "list all versions" do
        get wiki_page_versions_path
        assert_response :success
      end

      should "list all versions that match the search criteria" do
        get wiki_page_versions_path, params: {:search => {:wiki_page_id => @wiki_page.id}}
        assert_response :success
      end
    end

    context "show action" do
      should "render" do
        get wiki_page_version_path(@wiki_page.versions.first)
        assert_response :success
      end
    end

    context "diff action" do
      should "render" do
        get diff_wiki_page_versions_path, params: { thispage: @wiki_page.versions.first.id, otherpage: @wiki_page.versions.last.id }
        assert_response :success
      end
    end
  end
end
