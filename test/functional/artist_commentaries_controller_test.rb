require 'test_helper'

class ArtistCommentariesControllerTest < ActionController::TestCase
  context "The artist commentaries controller" do
    setup do
      @user = FactoryGirl.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"

      @commentary1 = FactoryGirl.create(:artist_commentary)
      @commentary2 = FactoryGirl.create(:artist_commentary)
    end

    teardown do
      CurrentUser.user = nil
    end

    context "index action" do
      should "render" do
        get :index
        assert_response :success
      end

      should "render with search params" do
        params = {
          search: {
            text_matches: @commentary1.original_title,
            post_id: @commentary1.post_id, 
            original_present: "yes",
            translated_present: "yes",
            post_tags_match: @commentary1.post.tag_array.first,
          }
        }

        get :index, params
        assert_response :success
      end
    end

    context "show action" do
      should "render" do
        get :show, { id: @commentary1.id }
        assert_redirected_to(@commentary1.post)

        get :show, { post_id: @commentary1.post_id }
        assert_redirected_to(@commentary1.post)
      end
    end

    context "create_or_update action" do
      should "render for create" do
        params = {
          artist_commentary: {
            original_title: "foo",
            post_id: FactoryGirl.create(:post).id,
          }
        }

        post :create_or_update, params, { user_id: @user.id }
        assert_redirected_to(ArtistCommentary.find_by_post_id(params[:artist_commentary][:post_id]))
      end

      should "render for update" do
        params = {
          artist_commentary: {
            post_id: @commentary1.post_id,
            original_title: "foo",
          }
        }

        post :create_or_update, params, { user_id: @user.id }
        assert_redirected_to(@commentary1)
        assert_equal("foo", @commentary1.reload.original_title)
      end
    end

    context "revert action" do
      should "work" do
        original_title = @commentary1.original_title
        @commentary1.update(original_title: "foo")

        post :revert, { :id => @commentary1.post_id, :version_id => @commentary1.versions(true).first.id }, {:user_id => @user.id}
        assert_redirected_to(@commentary1)
        assert_equal(original_title, @commentary1.reload.original_title)
      end

      should "return 404 when trying to revert a nonexistent commentary" do
        post :revert, { :id => -1, :version_id => -1 }, {:user_id => @user.id}

        assert_response 404
      end

      should "not allow reverting to a previous version of another artist commentary" do
        post :revert, { :id => @commentary1.post_id, :version_id => @commentary2.versions(true).first.id }, {:user_id => @user.id}
        @commentary1.reload

        assert_not_equal(@commentary1.original_title, @commentary2.original_title)
        assert_response :missing
      end
    end
  end
end
