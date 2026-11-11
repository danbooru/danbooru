require "test_helper"

class SiteCredentialTest < ActiveSupport::TestCase
  context "A site credential" do
    setup do
      @credential = create(:site_credential, metadata: { rate_limit: { TweetDetail: { remaining: 281, limit: 300 }}})
    end

    should "merge metadata with existing metadata when used successfully" do
      @credential.reload.success!(rate_limit: { TweetDetail: { remaining: 38 }})

      assert_equal({ "rate_limit" => { "TweetDetail" => { "remaining" => 38, "limit" => 300 }}}, @credential.reload.metadata)
    end

    should "merge metadata with existing metadata when used unsuccessfully" do
      @credential.reload.error!(:rate_limited, rate_limit: { TweetDetail: { remaining: 0 }})

      assert_equal({ "rate_limit" => { "TweetDetail" => { "remaining" => 0, "limit" => 300 }}}, @credential.reload.metadata)
    end
  end
end
