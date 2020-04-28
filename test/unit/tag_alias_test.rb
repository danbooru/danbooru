require 'test_helper'

class TagAliasTest < ActiveSupport::TestCase
  context "A tag alias" do
    setup do
      @admin = FactoryBot.create(:admin_user)

      travel_to(1.month.ago) do
        user = FactoryBot.create(:user)
        CurrentUser.user = user
      end
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
        FactoryBot.create(:tag_alias, :antecedent_name => "aaa", :consequent_name => "bbb", :status => "active")
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

      # should_not allow_value(nil).for(:creator_id) # XXX https://github.com/thoughtbot/shoulda-context/issues/53
      should_not allow_value(-1).for(:creator_id).with_message("must exist", against: :creator)

      should "not allow duplicate active aliases" do
        ta1 = FactoryBot.create(:tag_alias, antecedent_name: "aaa", consequent_name: "bbb", status: "active")
        ta2 = FactoryBot.create(:tag_alias, antecedent_name: "aaa", consequent_name: "bbb", status: "retired")
        ta3 = FactoryBot.create(:tag_alias, antecedent_name: "aaa", consequent_name: "bbb", status: "deleted")
        ta4 = FactoryBot.create(:tag_alias, antecedent_name: "aaa", consequent_name: "bbb", status: "deleted")
        ta5 = FactoryBot.create(:tag_alias, antecedent_name: "aaa", consequent_name: "bbb", status: "pending")
        [ta1, ta2, ta3, ta4, ta5].each { |ta| assert(ta.valid?) }

        ta5.update(status: "active")
        assert_includes(ta5.errors[:antecedent_name], "has already been taken")
      end
    end

    context "#reject!" do
      should "not be blocked by validations" do
        ta1 = create(:tag_alias, antecedent_name: "kitty", consequent_name: "kitten", status: "active")
        ta2 = build(:tag_alias, antecedent_name: "cat", consequent_name: "kitty", status: "pending")

        ta2.reject!
        assert_equal("deleted", ta2.reload.status)
      end
    end

    context "on secondary validation" do
      should "warn about missing wiki pages" do
        ti = FactoryBot.build(:tag_alias, antecedent_name: "aaa", consequent_name: "bbb", skip_secondary_validations: false)

        assert(ti.invalid?)
        assert_includes(ti.errors[:base], "The bbb tag needs a corresponding wiki page")
      end

      should "warn about conflicting wiki pages" do
        FactoryBot.create(:wiki_page, title: "aaa", body: "aaa")
        FactoryBot.create(:wiki_page, title: "bbb", body: "bbb")
        ti = FactoryBot.build(:tag_alias, antecedent_name: "aaa", consequent_name: "bbb", skip_secondary_validations: false)

        assert(ti.invalid?)
        assert_includes(ti.errors[:base], "The tag alias [[aaa]] -> [[bbb]] has conflicting wiki pages. [[bbb]] should be updated to include information from [[aaa]] if necessary.")
      end
    end

    should "populate the creator information" do
      ta = create(:tag_alias, antecedent_name: "aaa", consequent_name: "bbb", creator: CurrentUser.user)
      assert_equal(CurrentUser.user.id, ta.creator_id)
    end

    should "convert a tag to its normalized version" do
      tag1 = create(:tag, name: "aaa")
      tag2 = create(:tag, name: "bbb")
      ta = create(:tag_alias, antecedent_name: "aaa", consequent_name: "bbb")

      assert_equal(["bbb"], TagAlias.to_aliased("aaa"))
      assert_equal(["bbb"], TagAlias.to_aliased("aaa".mb_chars))
      assert_equal(["bbb", "ccc"], TagAlias.to_aliased(["aaa", "ccc"]))
      assert_equal(["ccc", "bbb"], TagAlias.to_aliased(["ccc", "bbb"]))
      assert_equal(["bbb", "bbb"], TagAlias.to_aliased(["aaa", "aaa"]))
    end

    context "saved searches" do
      should "move saved searches" do
        tag1 = FactoryBot.create(:tag, :name => "...")
        tag2 = FactoryBot.create(:tag, :name => "bbb")
        ss = FactoryBot.create(:saved_search, :query => "123 ... 456", :user => CurrentUser.user)
        ta = FactoryBot.create(:tag_alias, :antecedent_name => "...", :consequent_name => "bbb")

        ta.approve!(approver: @admin)
        perform_enqueued_jobs

        assert_equal(%w(123 456 bbb), ss.reload.query.split.sort)
      end
    end

    should "update any affected posts when saved" do
      post1 = FactoryBot.create(:post, :tag_string => "aaa bbb")
      post2 = FactoryBot.create(:post, :tag_string => "ccc ddd")

      ta = FactoryBot.create(:tag_alias, :antecedent_name => "aaa", :consequent_name => "ccc")
      ta.approve!(approver: @admin)
      perform_enqueued_jobs

      assert_equal("bbb ccc", post1.reload.tag_string)
      assert_equal("ccc ddd", post2.reload.tag_string)
    end

    should "not validate for transitive relations" do
      ta1 = FactoryBot.create(:tag_alias, :antecedent_name => "bbb", :consequent_name => "ccc")
      assert_difference("TagAlias.count", 0) do
        ta2 = FactoryBot.build(:tag_alias, :antecedent_name => "aaa", :consequent_name => "bbb")
        ta2.save
        assert(ta2.errors.any?, "Tag alias should be invalid")
        assert_equal("A tag alias for bbb already exists", ta2.errors.full_messages.join)
      end
    end

    should "move existing wikis" do
      wiki = create(:wiki_page, title: "aaa")
      ta = create(:tag_alias, antecedent_name: "aaa", consequent_name: "bbb", status: "pending")

      ta.approve!(approver: @admin)
      perform_enqueued_jobs

      assert_equal("bbb", wiki.reload.title)
    end

    should "move existing aliases" do
      ta1 = FactoryBot.create(:tag_alias, :antecedent_name => "aaa", :consequent_name => "bbb", :status => "pending")
      ta2 = FactoryBot.create(:tag_alias, :antecedent_name => "bbb", :consequent_name => "ccc", :status => "pending")

      # XXX this is broken, it depends on the order the jobs are executed in.
      ta2.approve!(approver: @admin)
      ta1.approve!(approver: @admin)
      perform_enqueued_jobs

      assert_equal("ccc", ta1.reload.consequent_name)
    end

    should "move existing implications" do
      ti = FactoryBot.create(:tag_implication, :antecedent_name => "aaa", :consequent_name => "bbb")
      ta = FactoryBot.create(:tag_alias, :antecedent_name => "bbb", :consequent_name => "ccc")
      ta.approve!(approver: @admin)
      perform_enqueued_jobs

      assert_equal("ccc", ti.reload.consequent_name)
    end

    should "push the consequent's category to the antecedent if the antecedent is general" do
      tag1 = create(:tag, name: "general", category: 0)
      tag2 = create(:tag, name: "artist", category: 1)
      ta = create(:tag_alias, antecedent_name: "general", consequent_name: "artist")

      ta.approve!(approver: @admin)
      perform_enqueued_jobs

      assert_equal(1, tag1.reload.category)
      assert_equal(1, tag2.reload.category)
    end

    should "push the antecedent's category to the consequent if the consequent is general" do
      tag1 = create(:tag, name: "artist", category: 1)
      tag2 = create(:tag, name: "general", category: 0)
      ta = create(:tag_alias, antecedent_name: "artist", consequent_name: "general")

      ta.approve!(approver: @admin)
      perform_enqueued_jobs

      assert_equal(1, tag1.reload.category)
      assert_equal(1, tag2.reload.category)
    end

    should "not change either tag category when neither the antecedent or consequent are general" do
      tag1 = create(:tag, name: "character", category: 4)
      tag2 = create(:tag, name: "copyright", category: 3)
      ta = create(:tag_alias, antecedent_name: "character", consequent_name: "copyright")

      ta.approve!(approver: @admin)
      perform_enqueued_jobs

      assert_equal(4, tag1.reload.category)
      assert_equal(3, tag2.reload.category)
    end
  end
end
