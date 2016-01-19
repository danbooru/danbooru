require 'test_helper'

class ArtistVersionsControllerTest < ActionController::TestCase
  context "An artist versions controller" do
    setup do
      CurrentUser.user = FactoryGirl.create(:gold_user)
      CurrentUser.ip_addr = "127.0.0.1"
      @artist = FactoryGirl.create(:artist)
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    should "get the index page" do
      get :index, {}, {:user_id => CurrentUser.id}
      assert_response :success
    end

    should "get the index page when searching for something" do
      get :index, {:search => {:name => @artist.name}}, {:user_id => CurrentUser.id}
      assert_response :success
    end
  end
end
