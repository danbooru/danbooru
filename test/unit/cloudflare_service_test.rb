require 'test_helper'

class CloudflareServiceTest < ActiveSupport::TestCase
  def setup
    @cloudflare = CloudflareService.new(zone: "123", api_token: "foo")
  end

  context "#purge_cache" do
    should "make calls to cloudflare's api" do
      url = "http://www.example.com/file.jpg"
      mock_request("https://api.cloudflare.com/client/v4/zones/123/purge_cache", method: :delete, json: { files: [url] })

      response = @cloudflare.purge_cache([url])
      assert_equal(200, response.status)
    end
  end
end
