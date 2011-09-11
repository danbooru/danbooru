require 'test_helper'

class TagTest < ActiveSupport::TestCase
  setup do
    user = Factory.create(:user)
    CurrentUser.user = user
    CurrentUser.ip_addr = "127.0.0.1"
    MEMCACHE.flush_all
    Delayed::Worker.delay_jobs = false
  end
  
  teardown do
    CurrentUser.user = nil
    CurrentUser.ip_addr = nil
  end
  
  context "A tag category fetcher" do
    setup do
      MEMCACHE.flush_all
    end
    
    should "fetch for a single tag" do
      Factory.create(:artist_tag, :name => "test")
      assert_equal(Tag.categories.artist, Tag.category_for("test"))
    end

    should "fetch for a single tag with strange markup" do
      Factory.create(:artist_tag, :name => "!@$%")
      assert_equal(Tag.categories.artist, Tag.category_for("!@$%"))
    end
    
    should "fetch for multiple tags" do
      Factory.create(:artist_tag, :name => "aaa")
      Factory.create(:copyright_tag, :name => "bbb")
      categories = Tag.categories_for(%w(aaa bbb ccc))
      assert_equal(Tag.categories.artist, categories["aaa"])
      assert_equal(Tag.categories.copyright, categories["bbb"])
      assert_equal(0, categories["ccc"])
    end
  end
  
  context "A tag category mapping" do
    setup do
      MEMCACHE.flush_all
    end
    
    should "exist" do
      assert_nothing_raised {Tag.categories}
    end
    
    should "have convenience methods for the four main categories" do
      assert_equal(0, Tag.categories.general)
      assert_equal(1, Tag.categories.artist)
      assert_equal(3, Tag.categories.copyright)
      assert_equal(4, Tag.categories.character)
    end
    
    should "have a regular expression for matching category names and shortcuts" do
      regexp = Tag.categories.regexp
      
      assert_match(regexp, "artist")
      assert_match(regexp, "art")
      assert_match(regexp, "copyright")
      assert_match(regexp, "copy")
      assert_match(regexp, "co")
      assert_match(regexp, "character")
      assert_match(regexp, "char")
      assert_match(regexp, "ch")
      assert_no_match(regexp, "c")
      assert_no_match(regexp, "woodle")
    end
    
    should "map a category name to its value" do
      assert_equal(0, Tag.categories.value_for("general"))
      assert_equal(0, Tag.categories.value_for("gen"))
      assert_equal(1, Tag.categories.value_for("artist"))
      assert_equal(1, Tag.categories.value_for("art"))
      assert_equal(0, Tag.categories.value_for("unknown"))      
    end
  end
  
  context "A tag" do
    setup do
      MEMCACHE.flush_all
    end

    should "know its category name" do
      @tag = Factory.create(:artist_tag)
      assert_equal("Artist", @tag.category_name)
    end
    
    should "reset its category after updating" do
      tag = Factory.create(:artist_tag)
      assert_equal(Tag.categories.artist, MEMCACHE.get("tc:#{tag.name}"))

      tag.update_attribute(:category, Tag.categories.copyright)
      assert_equal(Tag.categories.copyright, MEMCACHE.get("tc:#{tag.name}"))
    end
  end
  
  context "A tag parser" do
    should "scan a query" do
      assert_equal(%w(aaa bbb), Tag.scan_query("aaa bbb"))
      assert_equal(%w(~aaa -bbb*), Tag.scan_query("~AAa -BBB* -bbb*"))
    end
    
    should "strip out invalid characters when scanning" do
      assert_equal(%w(aaa bbb), Tag.scan_tags("aaa bbb"))
      assert_equal(%w(-b_b_b_), Tag.scan_tags("-B,B;B* -b_b_b_"))
    end
    
    should "cast values" do
      assert_equal(2048, Tag.parse_cast("2kb", :filesize))
      assert_equal(2097152, Tag.parse_cast("2m", :filesize))
      assert_nothing_raised {Tag.parse_cast("2009-01-01", :date)}
      assert_nothing_raised {Tag.parse_cast("1234", :integer)}
      assert_nothing_raised {Tag.parse_cast("1234.56", :float)}
    end
    
    should "parse a query" do
      tag1 = Factory.create(:tag, :name => "abc")
      tag2 = Factory.create(:tag, :name => "acb")

      assert_equal(["abc"], Tag.parse_query("md5:abc")[:md5])
      assert_equal([:between, 1, 2], Tag.parse_query("id:1..2")[:post_id])
      assert_equal([:gte, 1], Tag.parse_query("id:1..")[:post_id])
      assert_equal([:lte, 2], Tag.parse_query("id:..2")[:post_id])
      assert_equal([:gt, 2], Tag.parse_query("id:>2")[:post_id])
      assert_equal([:lt, 3], Tag.parse_query("id:<3")[:post_id])

      Tag.expects(:normalize_tags_in_query).returns(nil)
      assert_equal(["acb"], Tag.parse_query("a*b")[:tags][:include])
    end
  end
  
  context "A tag" do
    should "be found when one exists" do
      tag = Factory.create(:tag)
      assert_difference("Tag.count", 0) do
        Tag.find_or_create_by_name(tag.name)
      end
    end
    
    should "change the type for an existing tag" do
      tag = Factory.create(:tag)
      assert_difference("Tag.count", 0) do
        assert_equal(Tag.categories.general, tag.category)
        Tag.find_or_create_by_name("artist:#{tag.name}")
        tag.reload
        assert_equal(Tag.categories.artist, tag.category)
      end
    end
    
    should "be created when one doesn't exist" do
      assert_difference("Tag.count", 1) do
        tag = Tag.find_or_create_by_name("hoge")
        assert_equal("hoge", tag.name)
        assert_equal(Tag.categories.general, tag.category)
      end
    end
    
    should "be created with the type when one doesn't exist" do
      assert_difference("Tag.count", 1) do
        tag = Tag.find_or_create_by_name("artist:hoge")
        assert_equal("hoge", tag.name)
        assert_equal(Tag.categories.artist, tag.category)
      end
    end
  end
end
