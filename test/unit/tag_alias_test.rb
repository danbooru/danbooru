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
      mock_saved_search_service!
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

    context "#estimate_update_count" do
      setup do
        FactoryBot.create(:post, tag_string: "aaa bbb ccc")
        @alias = FactoryBot.create(:tag_alias, antecedent_name: "aaa", consequent_name: "bbb", status: "pending")
      end

      should "get the right count" do
        assert_equal(1, @alias.estimate_update_count)
      end
    end

    context "#update_notice" do
      setup do
        @forum_topic = FactoryBot.create(:forum_topic)
      end

      should "update the cache" do
        FactoryBot.create(:tag_alias, antecedent_name: "aaa", consequent_name: "bbb", skip_secondary_validations: true, forum_topic: @forum_topic)
        assert_equal(@forum_topic.id, Cache.get("tcn:aaa"))
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
        assert_includes(ti.errors[:base], "The tag alias [[aaa]] -> [[bbb]]  has conflicting wiki pages. [[bbb]] should be updated to include information from [[aaa]] if necessary.")
      end
    end

    should "populate the creator information" do
      ta = FactoryBot.create(:tag_alias, :antecedent_name => "aaa", :consequent_name => "bbb")
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
      setup do
        SavedSearch.stubs(:enabled?).returns(true)
      end

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

    should "not push the antecedent's category to the consequent if the antecedent is general" do
      tag1 = FactoryBot.create(:tag, :name => "aaa")
      tag2 = FactoryBot.create(:tag, :name => "bbb", :category => 1)
      ta = FactoryBot.create(:tag_alias, :antecedent_name => "aaa", :consequent_name => "bbb")
      tag2.reload
      assert_equal(1, tag2.category)
    end

    should "push the antecedent's category to the consequent" do
      tag1 = FactoryBot.create(:tag, :name => "aaa", :category => 1)
      tag2 = FactoryBot.create(:tag, :name => "bbb", :category => 0)
      ta = FactoryBot.create(:tag_alias, :antecedent_name => "aaa", :consequent_name => "bbb")

      ta.approve!(approver: @admin)
      perform_enqueued_jobs

      assert_equal(1, tag2.reload.category)
    end

    context "with an associated forum topic" do
      setup do
        @admin = FactoryBot.create(:admin_user)
        CurrentUser.scoped(@admin) do
          @topic = FactoryBot.create(:forum_topic, :title => TagAliasRequest.topic_title("aaa", "bbb"))
          @post = FactoryBot.create(:forum_post, :topic_id => @topic.id, :body => TagAliasRequest.command_string("aaa", "bbb"))
          @alias = FactoryBot.create(:tag_alias, :antecedent_name => "aaa", :consequent_name => "bbb", :forum_topic => @topic, :forum_post => @post, :status => "pending")
        end
      end

      context "and conflicting wiki pages" do
        setup do
          CurrentUser.scoped(@admin) do
            @wiki1 = FactoryBot.create(:wiki_page, :title => "aaa")
            @wiki2 = FactoryBot.create(:wiki_page, :title => "bbb")
            @alias.approve!(approver: @admin)
            perform_enqueued_jobs
          end
        end

        should "update the forum topic when approved" do
          assert_equal("[APPROVED] Tag alias: aaa -> bbb", @topic.reload.title)
          assert_match(/The tag alias .* been approved/m, @topic.posts.second.body)
        end

        should "warn about conflicting wiki pages when approved" do
          assert_match(/has conflicting wiki pages/m, @topic.posts.third.body)
        end
      end

      should "update the topic when processed" do
        assert_difference("ForumPost.count") do
          @alias.approve!(approver: @admin)
          perform_enqueued_jobs
        end
      end

      should "update the parent post" do
        previous = @post.body
        @alias.approve!(approver: @admin)
        perform_enqueued_jobs
        assert_not_equal(previous, @post.reload.body)
      end

      should "update the topic when rejected" do
        assert_difference("ForumPost.count") do
          @alias.reject!
        end
      end

      should "update the topic when failed" do
        @alias.stubs(:sleep).returns(true)
        @alias.stubs(:update_posts).raises(Exception, "oh no")
        @alias.process!

        assert_equal("[FAILED] Tag alias: aaa -> bbb", @topic.reload.title)
        assert_match(/error: oh no/, @alias.status)
        assert_match(/The tag alias .* failed during processing/, @topic.posts.last.body)
      end
    end
  end
end
