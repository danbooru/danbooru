# encoding: UTF-8

require 'test_helper'

class PixivProxyTest < ActiveSupport::TestCase
  context "The proxy" do
    should "get a single post" do
      results = PixivProxy.get_single("http://www.pixiv.net/member_illust.php?mode=medium&illust_id=9646484")
      assert_equal("member.php?id=4015", results[:profile_url])
      assert(results[:jp_tags].size > 0)
      first_tag = results[:jp_tags][0]
      assert_equal(2, first_tag.size)
      assert(first_tag[0] =~ /./)
      assert(first_tag[1] =~ /tags\.php\?tag=/)
    end
    
    should "get a manga page" do
      url ="http://img65.pixiv.net/img/kiyoringo/21755794_p2.png"
      results = PixivProxy.get_single(url)
      assert_equal("member.php?id=4015", results[:profile_url])
      assert(results[:jp_tags].size > 0)
      first_tag = results[:jp_tags][0]
      assert_equal(2, first_tag.size)
      assert(first_tag[0] =~ /./)
      assert(first_tag[1] =~ /tags\.php\?tag=/)
    end
  end
end
