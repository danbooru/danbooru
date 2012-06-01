require 'test_helper'

class AdvertisementHitsControllerTest < ActionController::TestCase
  context "An advertisement hits controller" do
    setup do
      @ad = FactoryGirl.create(:advertisement)
      @advertiser = FactoryGirl.create(:admin_user)
    end

    should "create a new hit" do
      assert_difference("AdvertisementHit.count", 1) do
        post :create, {:advertisement_id => @ad.id}
      end
      assert_redirected_to(@ad.referral_url)
    end
  end
end
