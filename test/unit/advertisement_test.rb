require File.expand_path('../../test_helper',  __FILE__)

class AdvertisementTest < ActiveSupport::TestCase
  context "An advertisement" do
    should "create new hit records" do
      ad = Factory.create(:advertisement)
      assert_difference("AdvertisementHit.count") do
        ad.hit!("0.0.0.0")
      end
      assert_equal("0.0.0.0", AdvertisementHit.first.ip_addr)
      assert_equal(1, AdvertisementHit.first.advertisement_id)
      assert_equal(1, ad.hit_sum(1.day.ago, 1.day.from_now))
      assert_equal(0, ad.hit_sum(2.days.ago, 1.day.ago))
    end
  end
end
