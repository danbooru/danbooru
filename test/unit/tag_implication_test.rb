require 'test_helper'

class TagImplicationTest < ActiveSupport::TestCase
  context "A tag implication" do
    setup do
      user = FactoryBot.create(:admin_user)
      CurrentUser.user = user
      CurrentUser.ip_addr = "127.0.0.1"
      @user = FactoryBot.create(:user)
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "on validation" do
      subject do
        FactoryBot.create(:tag, :name => "aaa")
        FactoryBot.create(:tag, :name => "bbb")
        FactoryBot.create(:tag_implication, :antecedent_name => "aaa", :consequent_name => "bbb")
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

      should "not allow duplicate active implications" do
        ti1 = FactoryBot.create(:tag_implication, antecedent_name: "aaa", consequent_name: "bbb", status: "active")
        ti2 = FactoryBot.create(:tag_implication, antecedent_name: "aaa", consequent_name: "bbb", status: "retired")
        ti3 = FactoryBot.create(:tag_implication, antecedent_name: "aaa", consequent_name: "bbb", status: "deleted")
        ti4 = FactoryBot.create(:tag_implication, antecedent_name: "aaa", consequent_name: "bbb", status: "deleted")
        ti5 = FactoryBot.create(:tag_implication, antecedent_name: "aaa", consequent_name: "bbb", status: "pending")
        [ti1, ti2, ti3, ti4, ti5].each { |ti| assert(ti.valid?) }

        ti5.update(status: "active")
        assert_includes(ti5.errors[:antecedent_name], "has already been taken")
      end
    end

    context "#estimate_update_count" do
      setup do
        FactoryBot.create(:post, tag_string: "aaa bbb ccc")
        @implication = FactoryBot.create(:tag_implication, antecedent_name: "aaa", consequent_name: "bbb", status: "pending")
      end

      should "get the right count" do
        assert_equal(1, @implication.estimate_update_count)
      end
    end

    context "#update_notice" do
      setup do
        @mock_redis = MockRedis.new
        @forum_topic = FactoryBot.create(:forum_topic)
        TagChangeNoticeService.stubs(:redis_client).returns(@mock_redis)
      end

      should "update redis" do
        FactoryBot.create(:tag_implication, antecedent_name: "aaa", consequent_name: "bbb", skip_secondary_validations: true, forum_topic: @forum_topic)
        assert_equal(@forum_topic.id.to_s, @mock_redis.get("tcn:aaa"))
      end
    end

    context "on secondary validation" do
      should "warn if either tag is missing a wiki" do
        ti = FactoryBot.build(:tag_implication, antecedent_name: "aaa", consequent_name: "bbb", skip_secondary_validations: false)

        assert(ti.invalid?)
        assert_includes(ti.errors[:base], "The aaa tag needs a corresponding wiki page")
        assert_includes(ti.errors[:base], "The bbb tag needs a corresponding wiki page")
      end
    end

    should "ignore pending implications when building descendant names" do
      ti2 = FactoryBot.build(:tag_implication, :antecedent_name => "b", :consequent_name => "c", :status => "pending")
      ti2.save
      ti1 = FactoryBot.create(:tag_implication, :antecedent_name => "a", :consequent_name => "b")
      assert_equal(%w[b], ti1.descendant_names)
    end

    should "populate the creator information" do
      ti = FactoryBot.create(:tag_implication, :antecedent_name => "aaa", :consequent_name => "bbb")
      assert_equal(CurrentUser.user.id, ti.creator_id)
    end

    should "ensure both tags exist" do
      FactoryBot.create(:tag_implication, antecedent_name: "a", consequent_name: "b")

      assert(Tag.exists?(name: "a"))
      assert(Tag.exists?(name: "b"))
    end

    should "not validate when a tag directly implicates itself" do
      ti = FactoryBot.build(:tag_implication, antecedent_name: "a", consequent_name: "a")

      assert(ti.invalid?)
      assert_includes(ti.errors[:base], "Cannot alias or implicate a tag to itself")
    end

    should "not validate when a circular relation is created" do
      ti1 = FactoryBot.create(:tag_implication, :antecedent_name => "aaa", :consequent_name => "bbb")
      ti2 = FactoryBot.create(:tag_implication, :antecedent_name => "bbb", :consequent_name => "ccc")
      ti3 = FactoryBot.build(:tag_implication, :antecedent_name => "bbb", :consequent_name => "aaa")

      assert(ti1.valid?)
      assert(ti2.valid?)
      refute(ti3.valid?)
      assert_equal("Tag implication can not create a circular relation with another tag implication", ti3.errors.full_messages.join(""))
    end

    should "not validate when a transitive relation is created" do
      ti_ab = FactoryBot.create(:tag_implication, :antecedent_name => "a", :consequent_name => "b")
      ti_bc = FactoryBot.create(:tag_implication, :antecedent_name => "b", :consequent_name => "c")
      ti_ac = FactoryBot.build(:tag_implication, :antecedent_name => "a", :consequent_name => "c")
      ti_ac.save

      assert_equal("a already implies c through another implication", ti_ac.errors.full_messages.join(""))
    end

    should "not allow for duplicates" do
      ti1 = FactoryBot.create(:tag_implication, :antecedent_name => "aaa", :consequent_name => "bbb")
      ti2 = FactoryBot.build(:tag_implication, :antecedent_name => "aaa", :consequent_name => "bbb")
      ti2.save
      assert(ti2.errors.any?, "Tag implication should not have validated.")
      assert_includes(ti2.errors.full_messages, "Antecedent name has already been taken")
    end

    should "not validate if its antecedent or consequent are aliased to another tag" do
      ta1 = FactoryBot.create(:tag_alias, :antecedent_name => "aaa", :consequent_name => "a")
      ta2 = FactoryBot.create(:tag_alias, :antecedent_name => "bbb", :consequent_name => "b")
      ti = FactoryBot.build(:tag_implication, :antecedent_name => "aaa", :consequent_name => "bbb")

      assert(ti.invalid?)
      assert_includes(ti.errors[:base], "Antecedent tag must not be aliased to another tag")
      assert_includes(ti.errors[:base], "Consequent tag must not be aliased to another tag")
    end

    should "calculate all its descendants" do
      ti1 = FactoryBot.create(:tag_implication, :antecedent_name => "bbb", :consequent_name => "ccc")
      assert_equal(%w[ccc], ti1.descendant_names)
      ti2 = FactoryBot.create(:tag_implication, :antecedent_name => "aaa", :consequent_name => "bbb")
      assert_equal(%w[bbb ccc], ti2.descendant_names)
      ti1.reload
      assert_equal(%w[ccc], ti1.descendant_names)
    end

    should "update its descendants on save" do
      ti1 = FactoryBot.create(:tag_implication, :antecedent_name => "aaa", :consequent_name => "bbb", :status => "active")
      ti2 = FactoryBot.create(:tag_implication, :antecedent_name => "ccc", :consequent_name => "ddd", :status => "active")
      ti1.reload
      ti2.reload
      ti2.update(
        :antecedent_name => "bbb"
      )
      ti1.reload
      ti2.reload
      assert_equal(%w[bbb ddd], ti1.descendant_names)
      assert_equal(%w[ddd], ti2.descendant_names)
    end

    should "update the descendants for all of its parents on destroy" do
      ti1 = FactoryBot.create(:tag_implication, :antecedent_name => "aaa", :consequent_name => "bbb")
      ti2 = FactoryBot.create(:tag_implication, :antecedent_name => "xxx", :consequent_name => "bbb")
      ti3 = FactoryBot.create(:tag_implication, :antecedent_name => "bbb", :consequent_name => "ccc")
      ti4 = FactoryBot.create(:tag_implication, :antecedent_name => "ccc", :consequent_name => "ddd")
      ti1.reload
      ti2.reload
      ti3.reload
      ti4.reload
      assert_equal(%w[bbb ccc ddd], ti1.descendant_names)
      assert_equal(%w[bbb ccc ddd], ti2.descendant_names)
      assert_equal(%w[ccc ddd], ti3.descendant_names)
      assert_equal(%w[ddd], ti4.descendant_names)
      ti3.destroy
      ti1.reload
      ti2.reload
      ti4.reload
      assert_equal(%w[bbb], ti1.descendant_names)
      assert_equal(%w[bbb], ti2.descendant_names)
      assert_equal(%w[ddd], ti4.descendant_names)
    end

    should "update the descendants for all of its parents on create" do
      ti1 = FactoryBot.create(:tag_implication, :antecedent_name => "aaa", :consequent_name => "bbb")
      ti1.reload
      assert_equal("active", ti1.status)
      assert_equal(%w[bbb], ti1.descendant_names)

      ti2 = FactoryBot.create(:tag_implication, :antecedent_name => "bbb", :consequent_name => "ccc")
      ti1.reload
      ti2.reload
      assert_equal("active", ti1.status)
      assert_equal("active", ti2.status)
      assert_equal(%w[bbb ccc], ti1.descendant_names)
      assert_equal(%w[ccc], ti2.descendant_names)

      ti3 = FactoryBot.create(:tag_implication, :antecedent_name => "ccc", :consequent_name => "ddd")
      ti1.reload
      ti2.reload
      ti3.reload
      assert_equal(%w[bbb ccc ddd], ti1.descendant_names)
      assert_equal(%w[ccc ddd], ti2.descendant_names)

      ti4 = FactoryBot.create(:tag_implication, :antecedent_name => "ccc", :consequent_name => "eee")
      ti1.reload
      ti2.reload
      ti3.reload
      ti4.reload
      assert_equal(%w[bbb ccc ddd eee], ti1.descendant_names)
      assert_equal(%w[ccc ddd eee], ti2.descendant_names)
      assert_equal(%w[ddd], ti3.descendant_names)
      assert_equal(%w[eee], ti4.descendant_names)

      ti5 = FactoryBot.create(:tag_implication, :antecedent_name => "xxx", :consequent_name => "bbb")
      ti1.reload
      ti2.reload
      ti3.reload
      ti4.reload
      ti5.reload
      assert_equal(%w[bbb ccc ddd eee], ti1.descendant_names)
      assert_equal(%w[ccc ddd eee], ti2.descendant_names)
      assert_equal(%w[ddd], ti3.descendant_names)
      assert_equal(%w[eee], ti4.descendant_names)
      assert_equal(%w[bbb ccc ddd eee], ti5.descendant_names)
    end

    should "update any affected post upon save" do
      p1 = FactoryBot.create(:post, :tag_string => "aaa bbb ccc")
      ti1 = FactoryBot.create(:tag_implication, :antecedent_name => "aaa", :consequent_name => "xxx")
      ti2 = FactoryBot.create(:tag_implication, :antecedent_name => "aaa", :consequent_name => "yyy")
      ti1.approve!
      ti2.approve!

      assert_equal("aaa bbb ccc xxx yyy", p1.reload.tag_string)
    end

    context "with an associated forum topic" do
      setup do
        @admin = FactoryBot.create(:admin_user)
        @topic = FactoryBot.create(:forum_topic, :title => TagImplicationRequest.topic_title("aaa", "bbb"))
        @post = FactoryBot.create(:forum_post, topic_id: @topic.id, :body => TagImplicationRequest.command_string("aaa", "bbb"))
        @implication = FactoryBot.create(:tag_implication, :antecedent_name => "aaa", :consequent_name => "bbb", :forum_topic => @topic, :forum_post => @post, :status => "pending")
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
