require File.dirname(__FILE__) + '/../test_helper'

class TagImplicationTest < ActiveSupport::TestCase
  context "A tag implication" do
    setup do
      MEMCACHE.flush_all
      @user = Factory.create(:user)
    end

    should "clear the cache upon saving" do
      ti1 = Factory.create(:tag_implication, :antecedent_name => "aaa", :consequent_name => "bbb")
      assert_equal(["bbb"], ti1.descendant_names_array)
      assert_equal(["bbb"], MEMCACHE.get("ti:aaa"))
      ti1.update_attributes(
        :consequent_name => "ccc",
        :updater_id => @user.id,
        :updater_ip_addr => "127.0.0.1"
      )
      assert_nil(MEMCACHE.get("ti:aaa"))
    end
    
    # should "clear the cache upon destruction" do
    #   ti1 = Factory.create(:tag_implication, :antecedent_name => "aaa", :consequent_name => "bbb")
    #   assert_equal("bbb", ti1.descendant_names)
    #   assert_equal(["bbb"], ti1.descendant_names_array)
    #   assert_equal(["bbb"], MEMCACHE.get("ti:aaa"))
    #   ti1.destroy
    #   assert_nil(MEMCACHE.get("ti:aaa"))
    # end
    # 
    # should "calculate all its descendants" do
    #   ti1 = Factory.create(:tag_implication, :antecedent_name => "bbb", :consequent_name => "ccc")
    #   assert_equal(["ccc"], ti1.descendant_names_array)      
    #   ti2 = Factory.create(:tag_implication, :antecedent_name => "aaa", :consequent_name => "bbb")
    #   assert_equal(["bbb", "ccc"], ti2.descendant_names_array)
    #   ti1.reload
    #   assert_equal(["ccc"], ti1.descendant_names_array)
    # end
    
    should "cache its descendants"
    should "update its descendants on save"
    should "update the decendants for its parent on save"
    should "update any affected post upon save"
  end
end
