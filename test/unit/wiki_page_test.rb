require 'test_helper'

class WikiPageTest < ActiveSupport::TestCase
  setup do
    MEMCACHE.flush_all
  end
  
  teardown do
    CurrentUser.user = nil
    CurrentUser.ip_addr = nil
  end

  context "A wiki page" do
    context "updated by a janitor" do
      setup do
        @user = Factory.create(:janitor_user)
        CurrentUser.user = @user
        CurrentUser.ip_addr = "127.0.0.1"
        @wiki_page = Factory.create(:wiki_page)
      end
        
      should "allow the is_locked attribute to be updated" do
        @wiki_page.update_attributes(:is_locked => true)
        @wiki_page.reload
        assert_equal(true, @wiki_page.is_locked?)
      end
    end
    
    context "updated by a regular user" do
      setup do
        @user = Factory.create(:user)
        CurrentUser.user = @user
        CurrentUser.ip_addr = "127.0.0.1"
        @wiki_page = Factory.create(:wiki_page, :title => "HOT POTATO")
      end
      
      should "not allow the is_locked attribute to be updated" do
        @wiki_page.update_attributes(:is_locked => true)
        assert_equal(["Is locked can be modified by janitors only"], @wiki_page.errors.full_messages)
        @wiki_page.reload
        assert_equal(false, @wiki_page.is_locked?)
      end
      
      should "normalize its title" do
        assert_equal("hot_potato", @wiki_page.title)
      end

      should "search by title" do
        matches = WikiPage.titled("hot potato")
        assert_equal(1, matches.count)
        assert_equal("hot_potato", matches.first.title)
      end

      should "create versions" do
        assert_difference("WikiPageVersion.count") do
          @wiki_page = Factory.create(:wiki_page, :title => "xxx")
        end

        assert_difference("WikiPageVersion.count") do
          @wiki_page.title = "yyy"
          @wiki_page.save
        end
      end

      should "revert to a prior version" do
        @wiki_page.title = "yyy"
        @wiki_page.save
        version = WikiPageVersion.first
        @wiki_page.revert_to!(version)
        @wiki_page.reload
        assert_equal("hot_potato", @wiki_page.title)
      end

      should "differentiate between updater and creator" do
        another_user = Factory.create(:user)
        CurrentUser.scoped(another_user, "127.0.0.1") do
          @wiki_page.title = "yyy"
          @wiki_page.save
        end
        version = WikiPageVersion.first
        assert_not_equal(@wiki_page.creator_id, version.updater_id)      
      end
    end
  end
end
