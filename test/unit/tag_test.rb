require File.dirname(__FILE__) + '/../test_helper'

class TagTest < ActiveSupport::TestCase
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
  end
end
