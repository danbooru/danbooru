require File.dirname(__FILE__) + '/../test_helper'

class TagAliasTest < ActiveSupport::TestCase
  context "A tag alias" do
    setup do
      MEMCACHE.flush_all
    end
    
    should "convert a tag to its normalized version" do
      tag1 = Factory.create(:tag, :name => "aaa")
      tag2 = Factory.create(:tag, :name => "bbb")
      ta = Factory.create(:tag_alias, :antecedent_name => "aaa", :consequent_name => "bbb")
      normalized_tags = TagAlias.to_aliased(["aaa", "ccc"])
      assert_equal(["bbb", "ccc"], normalized_tags.sort)
    end
    
    should "update the cache" do
      tag1 = Factory.create(:tag, :name => "aaa")
      tag2 = Factory.create(:tag, :name => "bbb")
      ta = Factory.create(:tag_alias, :antecedent_name => "aaa", :consequent_name => "bbb")
      assert_equal("bbb", MEMCACHE.get("ta:aaa"))
    end
    
    should "update any affected posts when saved" do
      assert_equal(0, TagAlias.count)
      post1 = Factory.create(:post, :tag_string => "aaa bbb")
      post2 = Factory.create(:post, :tag_string => "ccc ddd")
      assert_equal("aaa bbb", post1.tag_string)
      assert_equal("ccc ddd", post2.tag_string)
      ta = Factory.create(:tag_alias, :antecedent_name => "aaa", :consequent_name => "ccc")
      post1.reload
      post2.reload
      assert_equal("ccc bbb", post1.tag_string)
      assert_equal("ccc ddd", post2.tag_string)
    end
  end
end
