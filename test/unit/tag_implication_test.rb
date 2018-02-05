require 'test_helper'

class TagImplicationTest < ActiveSupport::TestCase
  context "A tag implication" do
    setup do
      user = FactoryGirl.create(:admin_user)
      CurrentUser.user = user
      CurrentUser.ip_addr = "127.0.0.1"
      @user = FactoryGirl.create(:user)
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "on validation" do
      subject do
        FactoryGirl.create(:tag, :name => "aaa")
        FactoryGirl.create(:tag, :name => "bbb")
        FactoryGirl.create(:tag_implication, :antecedent_name => "aaa", :consequent_name => "bbb")
      end

      should allow_value('active').for(:status)
      should allow_value('deleted').for(:status)
      should allow_value('pending').for(:status)
      should allow_value('processing').for(:status)
      should allow_value('queued').for(:status)
      should allow_value('error: derp').for(:status)

      should_not allow_value('ACTIVE').for(:status)
      should_not allow_value('error').for(:status)
      should_not allow_value('derp').for(:status)

      should allow_value(nil).for(:forum_topic_id)
      should_not allow_value(-1).for(:forum_topic_id).with_message("must exist", against: :forum_topic)

      should allow_value(nil).for(:approver_id)
      should_not allow_value(-1).for(:approver_id).with_message("must exist", against: :approver)

      should_not allow_value(nil).for(:creator_id)
      should_not allow_value(-1).for(:creator_id).with_message("must exist", against: :creator)
    end

    should "ignore pending implications when building descendant names" do
      ti2 = FactoryGirl.build(:tag_implication, :antecedent_name => "b", :consequent_name => "c", :status => "pending")
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

    should "not validate when a transitive relation is created" do
      ti_ab = FactoryGirl.create(:tag_implication, :antecedent_name => "a", :consequent_name => "b")
      ti_bc = FactoryGirl.create(:tag_implication, :antecedent_name => "b", :consequent_name => "c")
      ti_ac = FactoryGirl.build(:tag_implication, :antecedent_name => "a", :consequent_name => "c")
      ti_ac.save

      assert_equal("a already implies c through another implication", ti_ac.errors.full_messages.join(""))
    end

    should "not allow for duplicates" do
      ti1 = FactoryGirl.create(:tag_implication, :antecedent_name => "aaa", :consequent_name => "bbb")
      ti2 = FactoryGirl.build(:tag_implication, :antecedent_name => "aaa", :consequent_name => "bbb")
      ti2.save
      assert(ti2.errors.any?, "Tag implication should not have validated.")
      assert_includes(ti2.errors.full_messages, "Antecedent name has already been taken")
    end

    should "not validate if its consequent is aliased to another tag" do
      ta = FactoryGirl.create(:tag_alias, :antecedent_name => "bbb", :consequent_name => "ccc")
      ti = FactoryGirl.build(:tag_implication, :antecedent_name => "aaa", :consequent_name => "bbb")
      ti.save
      assert(ti.errors.any?, "Tag implication should not have validated.")
      assert_equal("Consequent tag must not be aliased to another tag", ti.errors.full_messages.join(""))
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
      ti1.reload
      ti2.reload
      ti2.update_attributes(
        :antecedent_name => "bbb"
      )
      ti1.reload
      ti2.reload
      assert_equal("bbb ddd", ti1.descendant_names)
      assert_equal("ddd", ti2.descendant_names)
    end

    should "update the descendants for all of its parents on destroy" do
      ti1 = FactoryGirl.create(:tag_implication, :antecedent_name => "aaa", :consequent_name => "bbb")
      ti2 = FactoryGirl.create(:tag_implication, :antecedent_name => "xxx", :consequent_name => "bbb")
      ti3 = FactoryGirl.create(:tag_implication, :antecedent_name => "bbb", :consequent_name => "ccc")
      ti4 = FactoryGirl.create(:tag_implication, :antecedent_name => "ccc", :consequent_name => "ddd")
      ti1.reload
      ti2.reload
      ti3.reload
      ti4.reload
      assert_equal("bbb ccc ddd", ti1.descendant_names)
      assert_equal("bbb ccc ddd", ti2.descendant_names)
      assert_equal("ccc ddd", ti3.descendant_names)
      assert_equal("ddd", ti4.descendant_names)
      ti3.destroy
      ti1.reload
      ti2.reload
      ti4.reload
      assert_equal("bbb", ti1.descendant_names)
      assert_equal("bbb", ti2.descendant_names)
      assert_equal("ddd", ti4.descendant_names)
    end

    should "update the descendants for all of its parents on create" do
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

      ti5 = FactoryGirl.create(:tag_implication, :antecedent_name => "xxx", :consequent_name => "bbb")
      ti1.reload
      ti2.reload
      ti3.reload
      ti4.reload
      ti5.reload
      assert_equal("bbb ccc ddd eee", ti1.descendant_names)
      assert_equal("ccc ddd eee", ti2.descendant_names)
      assert_equal("ddd", ti3.descendant_names)
      assert_equal("eee", ti4.descendant_names)
      assert_equal("bbb ccc ddd eee", ti5.descendant_names)
    end

    should "update any affected post upon save" do
      p1 = FactoryGirl.create(:post, :tag_string => "aaa bbb ccc")
      ti1 = FactoryGirl.create(:tag_implication, :antecedent_name => "aaa", :consequent_name => "xxx")
      ti2 = FactoryGirl.create(:tag_implication, :antecedent_name => "aaa", :consequent_name => "yyy")
      p1.reload
      assert_equal("aaa bbb ccc xxx yyy", p1.tag_string)
    end

    context "with an associated forum topic" do
      setup do
        @admin = FactoryGirl.create(:admin_user)
        @topic = FactoryGirl.create(:forum_topic, :title => TagImplicationRequest.topic_title("aaa", "bbb"))
        @post = FactoryGirl.create(:forum_post, topic_id: @topic.id, :body => TagImplicationRequest.command_string("aaa", "bbb"))
        @implication = FactoryGirl.create(:tag_implication, :antecedent_name => "aaa", :consequent_name => "bbb", :forum_topic => @topic, :status => "pending")
      end

      should "update the topic when processed" do
        assert_difference("ForumPost.count") do
          @implication.approve!
        end
        @post.reload
        @topic.reload
        assert_match(/The tag implication .* has been approved/, @post.body)
        assert_equal("[APPROVED] Tag implication: aaa -> bbb", @topic.title)
      end

      should "update the topic when rejected" do
        assert_difference("ForumPost.count") do
          @implication.reject!
        end
        @post.reload
        @topic.reload
        assert_match(/The tag implication .* has been rejected/, @post.body)
        assert_equal("[REJECTED] Tag implication: aaa -> bbb", @topic.title)
      end
    end
  end
end
