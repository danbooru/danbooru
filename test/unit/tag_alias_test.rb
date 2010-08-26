require_relative '../test_helper'

class TagAliasTest < ActiveSupport::TestCase
  context "A tag alias" do
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
      ta.destroy
      assert_nil(MEMCACHE.get("ta:aaa"))
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
    
    should "not validate for transitive relations" do
      ta1 = Factory.create(:tag_alias, :antecedent_name => "aaa", :consequent_name => "bbb")
      assert_difference("TagAlias.count", 0) do
        ta3 = Factory.build(:tag_alias, :antecedent_name => "bbb", :consequent_name => "ddd")
        ta3.save
        assert(ta3.errors.any?, "Tag alias should be invalid")
        assert_equal("Tag alias can not create a transitive relation with another tag alias", ta3.errors.full_messages.join)
      end
    end
  end
end
