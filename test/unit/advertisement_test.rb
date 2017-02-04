require 'test_helper'
require 'helpers/upload_test_helper'

class AdvertisementTest < ActiveSupport::TestCase
  include UploadTestHelper

  context "An advertisement" do
    setup do
      Danbooru.config.stubs(:advertisement_path).returns("/tmp")
      @ad = FactoryGirl.create(:advertisement, :file => upload_jpeg("#{Rails.root}/test/files/test.jpg"))
    end

    teardown do
      FileUtils.rm_f(Dir.glob("#{Rails.root}/public/images/advertisements/*.jpg"))
    end

    should "create new hit records" do
      assert_difference("AdvertisementHit.count") do
        @ad.hit!("0.0.0.0")
      end
      assert_equal("0.0.0.0", AdvertisementHit.first.ip_addr.to_s)
      assert_equal(@ad.id, AdvertisementHit.first.advertisement_id)
      assert_equal(1, @ad.hit_sum(1.day.ago, 1.day.from_now))
      assert_equal(0, @ad.hit_sum(2.days.ago, 1.day.ago))
    end

    should "know its preview height and preview width" do
      assert_equal(100, @ad.preview_width)
      assert_equal(67, @ad.preview_height)
    end
  end
end
