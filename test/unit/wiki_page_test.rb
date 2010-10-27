require_relative '../test_helper'

class WikiPageTest < ActiveSupport::TestCase
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

  context "A wiki page" do
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
      
      assert_difference("WikiPageVersion.count") do
        wp = Factory.create(:wiki_page, :title => "xxx")
      end

      assert_difference("WikiPageVersion.count") do
        wp.title = "yyy"
        wp.save
      end
    end
    
    should "revert to a prior version" do
      wp = Factory.create(:wiki_page, :title => "xxx")
      wp.title = "yyy"
      wp.save
      version = WikiPageVersion.first
      wp.revert_to!(version)
      wp.reload
      assert_equal("xxx", wp.title)
    end
    
    should "differentiate between updater and creator" do
      user = Factory.create(:user)
      wp = Factory.create(:wiki_page, :title => "xxx")
      CurrentUser.scoped(user, "127.0.0.1") do
        wp.title = "yyy"
        wp.save
      end
      version = WikiPageVersion.first
      assert_not_equal(wp.creator_id, version.updater_id)      
    end
  end
end
