require 'test_helper'

class TagImplicationTest < ActiveSupport::TestCase
  context "A tag implication" do
    setup do
      @admin = create(:admin_user)
      CurrentUser.user = @admin
      CurrentUser.ip_addr = "127.0.0.1"
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
      should allow_value('error: derp').for(:status)

      should_not allow_value('ACTIVE').for(:status)
      should_not allow_value('error').for(:status)
      should_not allow_value('derp').for(:status)

      should allow_value(nil).for(:forum_topic_id)
      should_not allow_value(-1).for(:forum_topic_id).with_message("must exist", against: :forum_topic)

      should allow_value(nil).for(:approver_id)
      should_not allow_value(-1).for(:approver_id).with_message("must exist", against: :approver)

      # should_not allow_value(nil).for(:creator_id) # XXX https://github.com/thoughtbot/shoulda-context/issues/53
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

    context "#reject!" do
      should "not be blocked by alias validations" do
        ti = create(:tag_implication, antecedent_name: "cat", consequent_name: "animal", status: "pending")
        ta = create(:tag_alias, antecedent_name: "cat", consequent_name: "kitty", status: "active")

        ti.reject!
        assert_equal("deleted", ti.reload.status)
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

    should "populate the creator information" do
      ti = create(:tag_implication, antecedent_name: "aaa", consequent_name: "bbb", creator: CurrentUser.user)
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

    should "update any affected post upon save" do
      p1 = FactoryBot.create(:post, :tag_string => "aaa bbb ccc")
      ti1 = FactoryBot.create(:tag_implication, :antecedent_name => "aaa", :consequent_name => "xxx")
      ti2 = FactoryBot.create(:tag_implication, :antecedent_name => "aaa", :consequent_name => "yyy")

      ti1.approve!(@admin)
      ti2.approve!(@admin)
      perform_enqueued_jobs

      assert_equal("aaa bbb ccc xxx yyy", p1.reload.tag_string)
    end

    context "when calculating implied tags" do
      should "include tags for all active implications" do
        # a -> b -> c -> d; b -> b1; c -> c1
        create(:tag_implication, antecedent_name: "a", consequent_name: "b", status: "active")
        create(:tag_implication, antecedent_name: "b", consequent_name: "c", status: "active")
        create(:tag_implication, antecedent_name: "c", consequent_name: "d", status: "active")
        create(:tag_implication, antecedent_name: "b", consequent_name: "b1", status: "active")
        create(:tag_implication, antecedent_name: "c", consequent_name: "c1", status: "active")

        assert_equal(%w[b b1 c c1 d], TagImplication.tags_implied_by("a").map(&:name).sort)
        assert_equal(%w[b1 c c1 d], TagImplication.tags_implied_by("b").map(&:name).sort)
        assert_equal(%w[c1 d], TagImplication.tags_implied_by("c").map(&:name).sort)
        assert_equal([], TagImplication.tags_implied_by("b1").map(&:name).sort)
        assert_equal([], TagImplication.tags_implied_by("c1").map(&:name).sort)
        assert_equal([], TagImplication.tags_implied_by("d").map(&:name).sort)
      end

      should "not include inactive implications" do
        create(:tag_implication, antecedent_name: "a", consequent_name: "b", status: "active")
        create(:tag_implication, antecedent_name: "b", consequent_name: "c", status: "pending")
        create(:tag_implication, antecedent_name: "c", consequent_name: "d", status: "active")

        assert_equal(["b"], TagImplication.tags_implied_by("a").map(&:name))
        assert_equal([], TagImplication.tags_implied_by("b").map(&:name))
        assert_equal(["d"], TagImplication.tags_implied_by("c").map(&:name))
        assert_equal([], TagImplication.tags_implied_by("d").map(&:name))
      end
    end
  end
end
