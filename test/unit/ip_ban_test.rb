require File.dirname(__FILE__) + '/../test_helper'

class IpBanTest < ActiveSupport::TestCase
  def test_count_by_ip_addr
    comment = Factory.create(:comment)
    counts = IpBan.count_by_ip_addr("comments", [comment.creator_id])
    assert_equal([{"ip_addr" => "1.2.3.4", "count" => "1"}], counts)
  end
  
  def test_search
    post = create_post()
    comment = create_comment(post, :ip_addr => "1.2.3.4", :body => "aaa")
    counts = IpBan.search([comment.user_id])
    assert_equal([{"ip_addr" => "1.2.3.4", "count" => "1"}], counts["comments"])
  end
end
