require 'test_helper'
require 'webmock/minitest'

class CloudflareServiceTest < ActiveSupport::TestCase
  def setup
    @cloudflare = CloudflareService.new(zone: "123", api_token: "foo")
  end

  context "#purge_cache" do
    should "make calls to cloudflare's api" do
      stub_request(:any, "api.cloudflare.com")
      @cloudflare.purge_cache(["http://localhost/file.txt"])

      assert_requested(:delete, "https://api.cloudflare.com/client/v4/zones/123/purge_cache", times: 1)
    end
  end

  context "#ips" do
    should "work" do
      refute_empty(@cloudflare.ips)
    end
  end
end
