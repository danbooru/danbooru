require 'test_helper'

class ArtistCommentaryVersionsControllerTest < ActionController::TestCase
  context "The artist commentary versions controller" do
    context "index action" do
      should "render" do
        get :index
        assert_response :success
      end
    end
  end
end
