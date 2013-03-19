require 'test_helper'

class ArtistTest < ActiveSupport::TestCase
  context "An artist" do
    setup do
      user = FactoryGirl.create(:user)
      CurrentUser.user = user
      CurrentUser.ip_addr = "127.0.0.1"
      MEMCACHE.flush_all
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "with a matching tag alias" do
      setup do
        @tag_alias = FactoryGirl.create(:tag_alias, :antecedent_name => "aaa", :consequent_name => "bbb")
        @artist = FactoryGirl.create(:artist, :name => "aaa")
      end

      should "know it has an alias" do
        assert_equal(true, @artist.has_tag_alias?)
      end

      should "know its alias" do
        assert_equal("bbb", @artist.tag_alias_name)
      end
    end

    context "that has been banned" do
      setup do
        @post = FactoryGirl.create(:post, :tag_string => "aaa")
        @artist = FactoryGirl.create(:artist, :name => "aaa")
        @artist.ban!
        @post.reload
      end

      should "delete the post" do
        assert(@post.is_deleted?)
      end

      should "create a new tag implication" do
        assert_equal(1, TagImplication.where(:antecedent_name => "aaa", :consequent_name => "banned_artist").count)
      end
    end

    should "create a new wiki page to store any note information" do
      artist = nil
      assert_difference("WikiPage.count") do
        artist = FactoryGirl.create(:artist, :name => "aaa", :notes => "testing")
      end
      assert_equal("testing", artist.notes)
      assert_equal("testing", artist.wiki_page.body)
      assert_equal(artist.name, artist.wiki_page.title)
    end

    should "update the wiki page when notes are assigned" do
      artist = FactoryGirl.create(:artist, :name => "aaa", :notes => "testing")
      artist.update_attribute(:notes, "kokoko")
      artist.reload
      assert_equal("kokoko", artist.notes)
      assert_equal("kokoko", artist.wiki_page.body)
    end

    should "normalize its name" do
      artist = FactoryGirl.create(:artist, :name => "  AAA BBB  ")
      assert_equal("aaa_bbb", artist.name)
    end

    should "resolve ambiguous urls" do
      bobross = FactoryGirl.create(:artist, :name => "bob_ross", :url_string => "http://artists.com/bobross/image.jpg")
      bob = FactoryGirl.create(:artist, :name => "bob", :url_string => "http://artists.com/bob/image.jpg")
      matches = Artist.find_all_by_url("http://artists.com/bob/test.jpg")
      assert_equal(1, matches.size)
      assert_equal("bob", matches.first.name)
    end

    should "parse urls" do
      artist = FactoryGirl.create(:artist, :name => "rembrandt", :url_string => "http://rembrandt.com/test.jpg http://aaa.com")
      artist.reload
      assert_equal(["http://aaa.com", "http://rembrandt.com/test.jpg"], artist.urls.map(&:to_s).sort)
    end

    should "make sure old urls are deleted" do
      artist = FactoryGirl.create(:artist, :name => "rembrandt", :url_string => "http://rembrandt.com/test.jpg")
      artist.url_string = "http://not.rembrandt.com/test.jpg"
      artist.save
      artist.reload
      assert_equal(["http://not.rembrandt.com/test.jpg"], artist.urls.map(&:to_s).sort)
    end

    should "find matches by url" do
      a1 = FactoryGirl.create(:artist, :name => "rembrandt", :url_string => "http://rembrandt.com/x/test.jpg")
      a2 = FactoryGirl.create(:artist, :name => "subway", :url_string => "http://subway.com/x/test.jpg")
      a3 = FactoryGirl.create(:artist, :name => "minko", :url_string => "https://minko.com/x/test.jpg")

      assert_equal(["rembrandt"], Artist.find_all_by_url("http://rembrandt.com/x/test.jpg").map(&:name))
      assert_equal(["rembrandt"], Artist.find_all_by_url("http://rembrandt.com/x/another.jpg").map(&:name))
      assert_equal([], Artist.find_all_by_url("http://nonexistent.com/test.jpg").map(&:name))
      assert_equal(["minko"], Artist.find_all_by_url("https://minko.com/x/test.jpg").map(&:name))
      assert_equal(["minko"], Artist.find_all_by_url("http://minko.com/x/test.jpg").map(&:name))
    end

    should "not allow duplicates" do
      FactoryGirl.create(:artist, :name => "warhol", :url_string => "http://warhol.com/x/a/image.jpg\nhttp://warhol.com/x/b/image.jpg")
      assert_equal(["warhol"], Artist.find_all_by_url("http://warhol.com/x/test.jpg").map(&:name))
    end

    should "hide deleted artists" do
      FactoryGirl.create(:artist, :name => "warhol", :url_string => "http://warhol.com/a/image.jpg", :is_active => false)
      assert_equal([], Artist.find_all_by_url("http://warhol.com/a/image.jpg").map(&:name))
    end

    should "normalize its other names" do
      artist = FactoryGirl.create(:artist, :name => "a1", :other_names_comma => "aaa, bbb, ccc ddd")
      assert_equal("aaa, bbb, ccc_ddd", artist.other_names_comma)
    end

    should "search on its name should return results" do
      artist = FactoryGirl.create(:artist, :name => "artist")
      assert_not_nil(Artist.search(:name => "artist").first)
    end

    should "search on other names should return matches" do
      artist = FactoryGirl.create(:artist, :name => "artist", :other_names_comma => "aaa, ccc ddd")
      assert_nil(Artist.other_names_match("artist").first)
      assert_not_nil(Artist.other_names_match("aaa").first)
      assert_not_nil(Artist.other_names_match("ccc_ddd").first)
      assert_not_nil(Artist.search(:name => "other:aaa").first)
      assert_not_nil(Artist.search(:name => "aaa").first)
    end

    should "search on group name and return matches" do
      cat_or_fish = FactoryGirl.create(:artist, :name => "cat_or_fish")
      yuu = FactoryGirl.create(:artist, :name => "yuu", :group_name => "cat_or_fish")
      cat_or_fish.reload
      assert_equal("yuu", cat_or_fish.member_names)
      assert_not_nil(Artist.search(:name => "group:cat_or_fish").first)
    end

    should "have an associated wiki" do
      user = FactoryGirl.create(:user)
      CurrentUser.user = user
      artist = FactoryGirl.create(:artist, :name => "max", :wiki_page_attributes => {:title => "xxx", :body => "this is max"})
      assert_not_nil(artist.wiki_page)
      assert_equal("this is max", artist.wiki_page.body)

      artist.update_attributes({:wiki_page_attributes => {:id => artist.wiki_page.id, :body => "this is hoge mark ii"}})
      assert_equal("this is hoge mark ii", artist.wiki_page(true).body)
      CurrentUser.user = nil
    end

    should "revert to prior versions" do
      user = FactoryGirl.create(:user)
      reverter = FactoryGirl.create(:user)
      artist = nil
      assert_difference("ArtistVersion.count") do
        artist = FactoryGirl.create(:artist, :other_names => "yyy")
      end

      assert_difference("ArtistVersion.count") do
        artist.other_names = "xxx"
        artist.save
      end

      first_version = ArtistVersion.first
      assert_equal("yyy", first_version.other_names)
      artist.revert_to!(first_version)
      artist.reload
      assert_equal("yyy", artist.other_names)
    end
  end
end
