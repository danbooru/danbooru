require 'test_helper'

class PostVersionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)

    as(@user) do
      @post = create(:post, tag_string: "tagme", rating: "s", source: "blah")
      travel(2.hours) { @post.update(tag_string: "1 2", source: "xxx") }
      travel(4.hours) { @post.update(tag_string: "2 3", rating: "e") }
      @post2 = create(:post)
    end
  end

  context "The post versions controller" do
    context "index action" do
      setup do
      end

      should "list all versions" do
        get_auth post_versions_path, @user
        assert_response :success
        assert_select "#post-version-#{@post.versions[0].id}"
        assert_select "#post-version-#{@post.versions[1].id}"
        assert_select "#post-version-#{@post.versions[2].id}"
      end

      should "list all versions that match the search criteria" do
        get_auth post_versions_path, @user, params: {:search => {:post_id => @post.id}}
        assert_response :success
        assert_select "#post-version-#{@post2.versions[0].id}", false
      end

      should "list all versions for search[changed_tags]" do
        get post_versions_path, as: :json, params: { search: { changed_tags: "1" }}
        assert_response :success
        assert_equal @post.versions[1].id, response.parsed_body[1]["id"].to_i
        assert_equal @post.versions[2].id, response.parsed_body[0]["id"].to_i

        get post_versions_path, as: :json, params: { search: { changed_tags: "1 2" }}
        assert_response :success
        assert_equal @post.versions[1].id, response.parsed_body[0]["id"].to_i
      end

      should "list all versions for search[tag_matches]" do
        get post_versions_path, as: :json, params: { search: { tag_matches: "tagme" }}
        assert_response :success
        assert_equal @post.versions[0].id, response.parsed_body[0]["id"].to_i
        assert_equal 1, response.parsed_body.length
      end
    end

    context "undo action" do
      should "undo the edit" do
        put_auth undo_post_version_path(@post.versions.second), @user
        assert_response :redirect
        assert_equal("e", @post.reload.rating)
        assert_equal("3 tagme", @post.tag_string)
        assert_equal("blah", @post.source)
      end

      should "not allow non-members to undo edits" do
        put undo_post_version_path(@post.versions.first)
        assert_response 403
        assert_equal("2 3", @post.reload.tag_string)
      end
    end
  end
end
