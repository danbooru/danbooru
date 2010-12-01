require 'test_helper'

class ArtistVersionsControllerTest < ActionController::TestCase
  context "An artist versions controller" do
    setup do
      CurrentUser.user = Factory.create(:user)
      CurrentUser.ip_addr = "127.0.0.1"
      @artist = Factory.create(:artist)
    end
    
    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end
    
    should "render the index page" do
      get :index
      assert_response :success
    end
    
    should "render the index page when searching for something" do
      get :index, {:search => {:name_equals => @artist.name}}
      assert_response :success
    end
  end
end
