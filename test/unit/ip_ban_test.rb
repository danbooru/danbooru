require 'test_helper'

class IpBanTest < ActiveSupport::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    CurrentUser.user = @user
    CurrentUser.ip_addr = "127.0.0.1"
    Danbooru.config.stubs(:member_comment_time_threshold).returns(1.week.from_now)
  end

  teardown do
    CurrentUser.user = nil
    CurrentUser.ip_addr = nil
  end

  should "be able to count the number of comments an IP address is associated with" do
    comment = FactoryGirl.create(:comment)
    counts = IpBan.count_by_ip_addr("comments", [comment.creator_id], "creator_id", "ip_addr")
    assert_equal([{"ip_addr" => "127.0.0.1", "count" => "1"}], counts)
  end

  should "be able to count any updates from a user, groupiny by IP address" do
    CurrentUser.scoped(@user, "1.2.3.4") do
      comment = FactoryGirl.create(:comment, :body => "aaa")
      counts = IpBan.query([comment.creator_id])
      assert_equal([{"ip_addr" => "1.2.3.4", "count" => "1"}], counts["comments"])
    end
  end
end
