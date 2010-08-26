require_relative '../test_helper'

class IpBanTest < ActiveSupport::TestCase
  setup do
    user = Factory.create(:user)
    CurrentUser.user = user
    CurrentUser.ip_addr = "127.0.0.1"
    MEMCACHE.flush_all
  end
  
  teardown do
    CurrentUser.user = nil
    CurrentUser.ip_addr = nil
  end

  should "be able to count the number of comments an IP address is associated with" do
    comment = Factory.create(:comment)
    counts = IpBan.count_by_ip_addr("comments", [comment.creator_id], "creator_id", "ip_addr")
    assert_equal([{"ip_addr" => "127.0.0.1", "count" => "1"}], counts)
  end
  
  should "be able to count any updates from a user, groupiny by IP address" do
    comment = Factory.create(:comment, :ip_addr => "1.2.3.4", :body => "aaa")
    counts = IpBan.search([comment.creator_id])
    assert_equal([{"ip_addr" => "1.2.3.4", "count" => "1"}], counts["comments"])
  end
end
