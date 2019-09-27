require 'test_helper'

class PostVersionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
  end

  context "The post versions controller" do
    context "index action" do
      setup do
        @user.as_current do
          @post = create(:post)
          travel(2.hours) do
            @post.update(:tag_string => "1 2", :source => "xxx")
          end
          travel(4.hours) do
            @post.update(:tag_string => "2 3", :rating => "e")
          end
          @versions = @post.versions
          @post2 = create(:post)
        end
      end

      should "list all versions" do
        get_auth post_versions_path, @user
        assert_response :success
        assert_select "#post-version-#{@versions[0].id}"
        assert_select "#post-version-#{@versions[1].id}"
        assert_select "#post-version-#{@versions[2].id}"
      end

      should "list all versions that match the search criteria" do
        get_auth post_versions_path, @user, params: {:search => {:post_id => @post.id}}
        assert_response :success
        assert_select "#post-version-#{@post2.versions[0].id}", false
      end

      should "list all versions for search[changed_tags]" do
        get post_versions_path, as: :json, params: { search: { changed_tags: "1" }}
        assert_response :success
        assert_equal @versions[1].id, response.parsed_body[1]["id"].to_i
        assert_equal @versions[2].id, response.parsed_body[0]["id"].to_i

        get post_versions_path, as: :json, params: { search: { changed_tags: "1 2" }}
        assert_response :success
        assert_equal @versions[1].id, response.parsed_body[0]["id"].to_i
      end
    end
  end
end
