# encoding: UTF-8

require 'test_helper'

module Sources
  class SiteTest < ActiveSupport::TestCase
    context "The source site" do
      context "for pixiv" do
        setup do
          @site = Sources::Site.new("http://www.pixiv.net/member_illust.php?mode=medium&illust_id=9646484")
          @site.get
        end
        
        should "get a single post" do
          assert_equal("http://www.pixiv.net/member.php?id=4015", @site.profile_url)
          assert(@site.tags.size > 0)
          first_tag = @site.tags.first
          assert_equal(2, first_tag.size)
          assert(first_tag[0] =~ /./)
          assert(first_tag[1] =~ /tags\.php\?tag=/)
        end

        should "convert a page into a json representation" do
          assert_nothing_raised do
            @site.to_json
          end
        end
      end
    end
  end
end
