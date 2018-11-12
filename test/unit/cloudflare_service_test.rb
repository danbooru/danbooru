require 'test_helper'
require 'webmock/minitest'

class CloudflareServiceTest < ActiveSupport::TestCase
  def setup
    super

    Danbooru.config.stubs(:cloudflare_key).returns("xyz")
    Danbooru.config.stubs(:cloudflare_email).returns("abc")
    Danbooru.config.stubs(:cloudflare_zone).returns("123")
  end

  subject { CloudflareService.new }

  context "#delete" do
    setup do
      stub_request(:any, "api.cloudflare.com")
    end

    should "make calls to cloudflare's api" do
      subject.delete("md5", "png")
      assert_requested(:delete,  "https://api.cloudflare.com/client/v4/zones/123/purge_cache", times: 1) do |req|
        req.body =~ /danbooru\.donmai\.us/ && req.body =~ /safebooru\.donmai\.us/ && req.body =~ /sample/ && req.body =~ /preview/
      end
    end
  end

  context "#ips" do
    should "work" do
      refute_empty(subject.ips)
    end
  end
end
