require 'test_helper'

class ArtistCommentariesControllerTest < ActionController::TestCase
  context "The artist commentaries controller" do
    setup do
      @user = FactoryGirl.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
    end

    teardown do
      CurrentUser.user = nil
    end

    context "revert action" do
      setup do
        @commentary1 = FactoryGirl.create(:artist_commentary)
        @commentary2 = FactoryGirl.create(:artist_commentary)
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
