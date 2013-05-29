require 'test_helper'

class TagImplicationTest < ActiveSupport::TestCase
  context "A tag implication" do
    setup do
      user = FactoryGirl.create(:admin_user)
      CurrentUser.user = user
      CurrentUser.ip_addr = "127.0.0.1"
      @user = FactoryGirl.create(:user)
      MEMCACHE.flush_all
      Delayed::Worker.delay_jobs = false
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    should "ignore pending implications when building descendant names" do
      ti2 = FactoryGirl.build(:tag_implication, :antecedent_name => "b", :consequent_name => "c")
      ti2.save
      ti1 = FactoryGirl.create(:tag_implication, :antecedent_name => "a", :consequent_name => "b")
      assert_equal("b", ti1.descendant_names)
    end

    should "populate the creator information" do
      ti = FactoryGirl.create(:tag_implication, :antecedent_name => "aaa", :consequent_name => "bbb")
      assert_equal(CurrentUser.user.id, ti.creator_id)
    end

    should "not validate when a circular relation is created" do
      ti1 = FactoryGirl.create(:tag_implication, :antecedent_name => "aaa", :consequent_name => "bbb")
      ti2 = FactoryGirl.build(:tag_implication, :antecedent_name => "bbb", :consequent_name => "aaa")
      ti2.save
      assert(ti2.errors.any?, "Tag implication should not have validated.")
      assert_equal("Tag implication can not create a circular relation with another tag implication", ti2.errors.full_messages.join(""))
    end

    should "not allow for duplicates" do
      ti1 = FactoryGirl.create(:tag_implication, :antecedent_name => "aaa", :consequent_name => "bbb")
      ti2 = FactoryGirl.build(:tag_implication, :antecedent_name => "aaa", :consequent_name => "bbb")
      ti2.save
      assert(ti2.errors.any?, "Tag implication should not have validated.")
      assert_equal("Antecedent name has already been taken", ti2.errors.full_messages.join(""))
    end

    should "calculate all its descendants" do
      ti1 = FactoryGirl.create(:tag_implication, :antecedent_name => "bbb", :consequent_name => "ccc")
      assert_equal("ccc", ti1.descendant_names)
      assert_equal(["ccc"], ti1.descendant_names_array)
      ti2 = FactoryGirl.create(:tag_implication, :antecedent_name => "aaa", :consequent_name => "bbb")
      assert_equal("bbb ccc", ti2.descendant_names)
      assert_equal(["bbb", "ccc"], ti2.descendant_names_array)
      ti1.reload
      assert_equal("ccc", ti1.descendant_names)
      assert_equal(["ccc"], ti1.descendant_names_array)
    end

    should "update its descendants on save" do
      ti1 = FactoryGirl.create(:tag_implication, :antecedent_name => "aaa", :consequent_name => "bbb")
      ti2 = FactoryGirl.create(:tag_implication, :antecedent_name => "ccc", :consequent_name => "ddd")
      ti2.update_attributes(
        :antecedent_name => "bbb"
      )
      ti1.reload
      ti2.reload
      assert_equal("bbb ddd", ti1.descendant_names)
      assert_equal("ddd", ti2.descendant_names)
    end

    should "update the descendants for its parent on destroy" do
      ti1 = FactoryGirl.create(:tag_implication, :antecedent_name => "aaa", :consequent_name => "bbb")
      ti2 = FactoryGirl.create(:tag_implication, :antecedent_name => "bbb", :consequent_name => "ccc")
      ti3 = FactoryGirl.create(:tag_implication, :antecedent_name => "ccc", :consequent_name => "ddd")
      ti2.destroy
      ti1.reload
      ti3.reload
      assert_equal("bbb", ti1.descendant_names)
      assert_equal("ddd", ti3.descendant_names)
    end

    should "update the descendants for its parent on create" do
      ti1 = FactoryGirl.create(:tag_implication, :antecedent_name => "aaa", :consequent_name => "bbb")
      ti1.reload
      assert_equal("active", ti1.status)
      assert_equal("bbb", ti1.descendant_names)

      ti2 = FactoryGirl.create(:tag_implication, :antecedent_name => "bbb", :consequent_name => "ccc")
      ti1.reload
      ti2.reload
      assert_equal("active", ti1.status)
      assert_equal("active", ti2.status)
      assert_equal("bbb ccc", ti1.descendant_names)
      assert_equal("ccc", ti2.descendant_names)

      ti3 = FactoryGirl.create(:tag_implication, :antecedent_name => "ccc", :consequent_name => "ddd")
      ti1.reload
      ti2.reload
      ti3.reload
      assert_equal("bbb ccc ddd", ti1.descendant_names)
      assert_equal("ccc ddd", ti2.descendant_names)

      ti4 = FactoryGirl.create(:tag_implication, :antecedent_name => "ccc", :consequent_name => "eee")
      ti1.reload
      ti2.reload
      ti3.reload
      ti4.reload
      assert_equal("bbb ccc ddd eee", ti1.descendant_names)
      assert_equal("ccc ddd eee", ti2.descendant_names)
      assert_equal("ddd", ti3.descendant_names)
      assert_equal("eee", ti4.descendant_names)
    end

    should "update any affected post upon destroy" do
      ti1 = FactoryGirl.create(:tag_implication, :antecedent_name => "aaa", :consequent_name => "bbb")
      ti2 = FactoryGirl.create(:tag_implication, :antecedent_name => "bbb", :consequent_name => "ccc")
      ti3 = FactoryGirl.create(:tag_implication, :antecedent_name => "ccc", :consequent_name => "ddd")
      p1 = FactoryGirl.create(:post, :tag_string => "aaa")
      assert_equal("aaa bbb ccc ddd", p1.tag_string)
      ti2.destroy
      p1.reload
      assert_equal("aaa bbb ddd", p1.tag_string)
    end

    should "update any affected post upon save" do
      p1 = FactoryGirl.create(:post, :tag_string => "aaa bbb ccc")
      ti1 = FactoryGirl.create(:tag_implication, :antecedent_name => "aaa", :consequent_name => "xxx")
      ti2 = FactoryGirl.create(:tag_implication, :antecedent_name => "aaa", :consequent_name => "yyy")
      p1.reload
      assert_equal("aaa bbb ccc xxx yyy", p1.tag_string)
    end
  end
end
