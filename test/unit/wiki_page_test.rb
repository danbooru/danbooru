require 'test_helper'

class WikiPageTest < ActiveSupport::TestCase
  setup do
    CurrentUser.ip_addr = "127.0.0.1"
  end

  teardown do
    CurrentUser.user = nil
    CurrentUser.ip_addr = nil
  end

  context "A wiki page" do
    context "updated by a regular user" do
      setup do
        @user = FactoryBot.create(:user)
        CurrentUser.user = @user
        @wiki_page = FactoryBot.create(:wiki_page, :title => "HOT POTATO", :other_names => "foo*bar baz")
      end

      should "normalize its title" do
        assert_equal("hot_potato", @wiki_page.title)
      end

      should "normalize its other names" do
        @wiki_page.update(:other_names => "foo*bar baz baz 加賀（艦これ）")
        assert_equal(%w[foo*bar baz 加賀(艦これ)], @wiki_page.other_names)
      end

      should "search by title" do
        matches = WikiPage.titled("hot potato")
        assert_equal(1, matches.count)
        assert_equal("hot_potato", matches.first.title)
      end

      should "search other names with wildcards" do
        matches = WikiPage.search(other_names_match: "fo*")
        assert_equal([@wiki_page.id], matches.map(&:id))
      end

      should "create versions" do
        assert_difference("WikiPageVersion.count") do
          @wiki_page = FactoryBot.create(:wiki_page, :title => "xxx")
        end

        assert_difference("WikiPageVersion.count") do
          @wiki_page.title = "yyy"
          travel(1.day) do
            @wiki_page.save
          end
        end
      end

      should "revert to a prior version" do
        @wiki_page.title = "yyy"
        travel(1.day) do
          @wiki_page.save
        end
        version = WikiPageVersion.first
        @wiki_page.revert_to!(version)
        @wiki_page.reload
        assert_equal("hot_potato", @wiki_page.title)
      end

      should "update its dtext links" do
        @wiki_page.update!(body: "[[long hair]]")
        assert_equal(1, @wiki_page.dtext_links.size)
        assert_equal("wiki_link", @wiki_page.dtext_links.first.link_type)
        assert_equal("long_hair", @wiki_page.dtext_links.first.link_target)

        @wiki_page.update!(body: "http://www.google.com")
        assert_equal(1, @wiki_page.dtext_links.size)
        assert_equal("external_link", @wiki_page.dtext_links.first.link_type)
        assert_equal("http://www.google.com", @wiki_page.dtext_links.first.link_target)

        @wiki_page.update!(body: "nothing")
        assert_equal(0, @wiki_page.dtext_links.size)
      end
    end
  end
end
