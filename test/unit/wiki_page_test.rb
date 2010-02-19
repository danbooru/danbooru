require File.dirname(__FILE__) + '/../test_helper'

class WikiPageTest < ActiveSupport::TestCase
  context "A wiki page" do
    setup do
      MEMCACHE.flush_all
    end
    
    should "normalize its title" do
      wp = Factory.create(:wiki_page, :title => "HOT POTATO")
      assert_equal("hot_potato", wp.title)
    end
    
    should "search by title" do
      Factory.create(:wiki_page, :title => "HOT POTATO")
      matches = WikiPage.titled("hot potato")
      assert_equal(1, matches.count)
      assert_equal("hot_potato", matches.first.title)
    end
    
    should "create versions" do
      wp = nil
      user = Factory.create(:user)
      
      assert_difference("WikiPageVersion.count") do
        wp = Factory.create(:wiki_page, :title => "xxx")
      end

      assert_difference("WikiPageVersion.count") do
        wp.title = "yyy"
        wp.updater_id = user.id
        wp.updater_ip_addr = "127.0.0.1"
        wp.save
      end
      
      version = WikiPageVersion.first
      wp.revert_to!(version)
      
      assert_equal("xxx", wp.title)
    end
  end
end
