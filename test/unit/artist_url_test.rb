require 'test_helper'

class ArtistUrlTest < ActiveSupport::TestCase
  context "An artist url" do
    setup do
      MEMCACHE.flush_all
      CurrentUser.user = Factory.create(:user)
      CurrentUser.ip_addr = "127.0.0.1"
    end
    
    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    should "always add a trailing slash when normalized" do
      url = Factory.create(:artist_url, :url => "http://monet.com")
      assert_equal("http://monet.com", url.url)
      assert_equal("http://monet.com/", url.normalized_url)

      url = Factory.create(:artist_url, :url => "http://monet.com/")
      assert_equal("http://monet.com/", url.url)
      assert_equal("http://monet.com/", url.normalized_url)
    end

    should "normalize fc2 urls" do
      url = Factory.create(:artist_url, :url => "http://blog55.fc2.com/monet")
      assert_equal("http://blog55.fc2.com/monet", url.url)
      assert_equal("http://blog.fc2.com/monet/", url.normalized_url)

      url = Factory.create(:artist_url, :url => "http://blog-imgs-55.fc2.com/monet")
      assert_equal("http://blog-imgs-55.fc2.com/monet", url.url)
      assert_equal("http://blog.fc2.com/monet/", url.normalized_url)
    end
    
    should "normalize pixiv urls" do
      url = Factory.create(:artist_url, :url => "http://img55.pixiv.net/monet")
      assert_equal("http://img55.pixiv.net/monet", url.url)
      assert_equal("http://img.pixiv.net/monet/", url.normalized_url)
    end
  end
end
