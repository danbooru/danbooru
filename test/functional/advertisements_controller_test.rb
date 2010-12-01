require 'test_helper'

class AdvertisementsControllerTest < ActionController::TestCase
  context "An advertisement controller" do
    setup do
      @ad = Factory.create(:advertisement)
      @advertiser = Factory.create(:admin_user)
    end
    
    should "render the new page" do
      get :new, {}, {:user_id => @advertiser.id}
      assert_response :success
    end
    
    should "render the edit page" do
      get :edit, {:id => @ad.id}, {:user_id => @advertiser.id}
      assert_response :success
    end
    
    should "render the index page" do
      get :index, {}, {:user_id => @advertiser.id}
      assert_response :success
    end
    
    should "render the show page" do
      get :show, {:id => @ad.id}, {:user_id => @advertiser.id}
      assert_response :success
    end
    
    should "create an ad" do
      assert_difference("Advertisement.count", 1) do
        post :create, {:advertisement => Factory.attributes_for(:advertisement)}, {:user_id => @advertiser.id}
      end
      ad = Advertisement.last
      assert_redirected_to(advertisement_path(ad))
    end
    
    should "update an ad" do
      post :update, {:id => @ad.id, :advertisement => {:width => 100}}, {:user_id => @advertiser.id}
      ad = Advertisement.last
      assert_equal(100, ad.width)
      assert_redirected_to(advertisement_path(ad))
    end
    
    should "delete an ad" do
      assert_difference("Advertisement.count", -1) do
        post :destroy, {:id => @ad.id}, {:user_id => @advertiser.id}
      end
      assert_redirected_to(advertisements_path)
    end
    
    should "block non-advertisers" do
      regular_user = Factory.create(:user)
      get :index, {}, {:user_id => regular_user.id}
      assert_redirected_to("/static/access_denied")
    end
  end
end
