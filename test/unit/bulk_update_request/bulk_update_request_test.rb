require "test_helper"

class BulkUpdateRequestTest < ActiveSupport::TestCase
  context "for a bulk update request," do
    setup do
      @admin = create(:admin_user)
      CurrentUser.user = @admin
    end

    teardown do
      CurrentUser.user = nil
    end

    should_eventually "parse tags with tag type prefixes inside the script" do
      @bur = create(:bulk_update_request, script: "mass update aaa -> artist:bbb")
      assert_equal(%w[aaa bbb], @bur.tags)
    end

    context "when approving a BUR" do
      context "that has both implications and unimplications" do
        should "process them sequentially" do
          @bur = create_bur!("imply foo -> bar\nunimply foo -> bar", @admin)

          @ti = TagImplication.find_by(antecedent_name: "foo", consequent_name: "bar")
          assert_equal(true, @ti.present?)
          assert_equal(true, @ti.is_deleted?)
          assert_equal("approved", @bur.reload.status)
        end

        should "allow the flattening of an implication tree, ie (a -> b -> c) to (a -> c)" do
          @ti1 = create(:tag_implication, antecedent_name: "character_(costume)_(swimsuit)_(fate)", consequent_name: "character_(costume)_(fate)")
          @ti2 = create(:tag_implication, antecedent_name: "character_(costume)_(fate)", consequent_name: "character_(fate)")

          @script = <<~EOS
            unimply character_(costume)_(swimsuit)_(fate) -> character_(costume)_(fate)
            imply character_(costume)_(swimsuit)_(fate) -> character_(fate)
          EOS
          @bur = build(:bulk_update_request, script: @script)

          assert_equal(true, @bur.valid?)
          @bur.approve!(@admin)
          assert_equal("processing", @bur.reload.status)

          perform_enqueued_jobs(only: ProcessBulkUpdateRequestJob)
          assert_equal("approved", @bur.reload.status)

          assert_equal(true, @ti1.reload.is_deleted?)

          @ti = TagImplication.find_by(antecedent_name: "character_(costume)_(swimsuit)_(fate)", consequent_name: "character_(fate)")
          assert_equal(true, @ti.is_active?)
        end
      end

      context "that contains a mass update followed by an alias" do
        should "make the alias take effect after the mass update" do
          @p1 = create(:post, tag_string: "maid_dress")
          @p2 = create(:post, tag_string: "maid")

          @bur = create_bur!("mass update maid_dress -> maid dress\nalias maid_dress -> maid", @admin)

          assert_equal("dress maid", @p1.reload.tag_string)
          assert_equal("maid", @p2.reload.tag_string)
          assert_equal("approved", @bur.reload.status)
        end
      end

      context "that reverses an alias by removing and recreating it" do
        should "not fail with an alias conflict" do
          @ta = create(:tag_alias, antecedent_name: "rabbit", consequent_name: "bunny")
          @bur = create_bur!("unalias rabbit -> bunny\nalias bunny -> rabbit", @admin)

          assert_equal("deleted", @ta.reload.status)
          assert_equal("active", TagAlias.find_by(antecedent_name: "bunny", consequent_name: "rabbit").status)
          assert_equal("approved", @bur.reload.status)
        end
      end
    end

    context "when validating a script" do
      context "an unparseable script" do
        should "fail validation" do
          @script = <<~EOS
            create alias aaa -> 000
            create alias bbb > 111
            create alias ccc -> 222
          EOS

          assert_invalid_bur(
            script: @script,
            errors: ["Invalid line: create alias bbb > 111"],
          )
        end
      end

      context "a script with extra whitespace" do
        should "validate" do
          @script = %{
            create alias aaa -> 000

            create alias bbb -> 111
          }

          @bur = create(:bulk_update_request, script: @script)
          assert_equal(true, @bur.valid?)
        end
      end

      context "a bulk update request that is too long" do
        should "fail" do
          assert_invalid_bur(
            script: "nuke touhou\n" * 200,
            errors: ["Bulk update request is too long (maximum size: 100 lines). Split your request into smaller chunks and try again."],
          )
        end
      end

      context "a bulk update request with duplicate lines" do
        should "fail" do
          assert_invalid_bur(
            script: "imply a -> b\nimply b -> a\n" * 200,
            errors: ["Duplicate line found: create implication [[a]] -> [[b]]", "Duplicate line found: create implication [[b]] -> [[a]]"],
          )
        end
      end
    end

    context "when the script is updated" do
      should "update the BUR's list of affected tags" do
        create(:tag_alias, antecedent_name: "ccc", consequent_name: "222")
        create(:tag_implication, antecedent_name: "ddd", consequent_name: "333")
        create(:tag, name: "iii")

        @script = <<~EOS
          create alias aaa -> 000
          create implication bbb -> 111
          remove alias ccc -> 222
          remove implication ddd -> 333
          mass update eee id:1 -fff ~ggg hhh* -> 444 -555
          category iii -> meta
        EOS

        @bur = create(:bulk_update_request, script: "create alias aaa -> bbb")
        assert_equal(%w[aaa bbb], @bur.tags)

        @bur.update!(script: @script)
        assert_equal(%w[000 111 222 333 444 555 aaa bbb ccc ddd eee fff ggg iii], @bur.tags)
      end
    end

    context "on approval" do
      setup do
        @post = create(:post, tag_string: "foo aaa")
        @script = '
          create alias foo -> bar
          create implication bar -> baz
          mass update aaa -> bbb blah
        '

        @bur = create_bur!(@script, @admin)

        @ta = TagAlias.where(antecedent_name: "foo", consequent_name: "bar").first
        @ti = TagImplication.where(antecedent_name: "bar", consequent_name: "baz").first
      end

      should "set the BUR approver" do
        assert_equal(@admin.id, @bur.approver.id)
      end

      should "create aliases/implications" do
        assert_equal("active", @ta.status)
        assert_equal("active", @ti.status)
      end

      should "process mass updates" do
        assert_equal("aaa bar baz bbb blah", @post.reload.tag_string)
      end

      should "set the alias/implication approvers" do
        assert_equal(@admin.id, @ta.approver.id)
        assert_equal(@admin.id, @ti.approver.id)
      end

      should "set the BUR as approved" do
        assert_equal("approved", @bur.reload.status)
      end

      should "update the post as DanbooruBot" do
        assert_equal(User.system, @post.versions.last.updater)
      end

      should "set the BUR as failed if there is an unexpected error during processing" do
        @bur = create(:bulk_update_request, script: "alias one -> two")
        TagAlias.any_instance.stubs(:process!).raises(RuntimeError.new("oh no"))

        assert_equal("pending", @bur.status)
        @bur.approve!(@admin)
        assert_equal("processing", @bur.status)

        assert_raises(RuntimeError) { perform_enqueued_jobs(only: ProcessBulkUpdateRequestJob) }
        assert_equal("failed", @bur.reload.status)

        assert_equal("active", TagAlias.find_by!(antecedent_name: "one", consequent_name: "two").status)
        assert_equal("alias one -> two", @bur.script)
        assert_equal(@admin, @bur.approver)
      end
    end

    context "when a bulk update request fails" do
      should "allow it to be approved again" do
        @post = create(:post, tag_string: "foo aaa")
        @bur = create(:bulk_update_request, script: "alias foo -> bar")

        TagAlias.any_instance.stubs(:process!).raises(RuntimeError.new("oh no"))
        @bur.approve!(@admin)
        assert_raises(RuntimeError) { perform_enqueued_jobs(only: ProcessBulkUpdateRequestJob) }

        assert_equal("aaa foo", @post.reload.tag_string)

        assert_equal("failed", @bur.reload.status)
        assert_not_nil(@bur.forum_topic)
        assert_equal(@admin, @bur.approver)

        @ta = TagAlias.find_by!(antecedent_name: "foo", consequent_name: "bar")
        assert_equal("active", @ta.status)
        assert_equal(@admin, @ta.approver)
        assert_equal(@bur.forum_topic, @ta.forum_topic)

        TagAlias.any_instance.unstub(:process!)
        @bur.approve!(@admin)
        perform_enqueued_jobs(only: ProcessBulkUpdateRequestJob)

        assert_equal("aaa bar", @post.reload.tag_string)

        assert_equal("approved", @bur.reload.status)
        assert_not_nil(@bur.forum_topic)
        assert_equal(@admin, @bur.approver)

        assert_equal("active", @ta.reload.status)
        assert_equal(@admin, @ta.approver)
        assert_equal(@bur.forum_topic, @ta.forum_topic)
      end
    end

    should "create a forum topic" do
      user = create(:user)
      bur = create(:bulk_update_request, user: user, reason: "zzz", script: "create alias aaa -> bbb")

      assert_equal(true, bur.forum_post.present?)
      assert_match(/\[bur:#{bur.id}\]/, bur.forum_post.body)
      assert_match(/zzz/, bur.forum_post.body)
      assert_equal(user, bur.forum_topic.creator)
      assert_equal(user, bur.forum_topic.updater)
      assert_equal(user, bur.forum_post.creator)
      assert_equal(user, bur.forum_post.updater)
    end

    context "with an associated forum topic" do
      setup do
        @topic = create(:forum_topic, title: "[bulk] hoge", creator: @admin)
        @post = create(:forum_post, topic: @topic, creator: @admin)
        @req = create(:bulk_update_request, script: "create alias AAA -> BBB", forum_topic: @topic, forum_post: @post)
      end

      should "leave the BUR pending if there is a validation error during approval" do
        @req.stubs(:update!).raises(BulkUpdateRequestProcessor::Error.new("blah"))
        assert_equal("pending", @req.reload.status)
      end

      should "leave the BUR pending if there is an unexpected error during approval" do
        @req.forum_updater.stubs(:update).raises(RuntimeError.new("blah"))
        assert_raises(RuntimeError) { @req.approve!(@admin) }

        # XXX Raises "Couldn't find BulkUpdateRequest without an ID". Possible
        # rails bug? (cf rails #34637, #34504, #30167, #15018).
        # @req.reload

        @req = BulkUpdateRequest.find(@req.id)
        assert_equal("pending", @req.status)
      end

      should "create a forum post on approval" do
        @req.approve!(@admin)

        assert_equal("processing", @req.status)
        assert_equal(%{The "bulk update request ##{@req.id}":/bulk_update_requests?search%5Bid%5D=#{@req.id} (forum ##{@post.id}) has been approved by @#{@admin.name}.}, @topic.forum_posts.last.body)
        assert_equal(User.system, @topic.forum_posts.last.creator)
        assert_equal(User.system, @topic.forum_posts.last.updater)
      end

      should "not send @mention dmails to the approver" do
        assert_no_difference("Dmail.count") do
          @req.approve!(@admin)
        end
      end
    end

    context "that doesn't belong to a forum post" do
      should "not fail to be rejected" do
        bur = create(:bulk_update_request)
        bur.update!(forum_post: nil)

        assert_nil(bur.forum_post)
        bur.reject!

        assert_equal("rejected", bur.status)
      end

      should "not fail to be approved" do
        bur = create(:bulk_update_request)
        bur.update!(forum_post: nil)

        assert_nil(bur.forum_post)
        bur.approve!(create(:admin_user))

        assert_equal("processing", bur.status)
      end
    end

    context "when validating a new bulk update request" do
      subject { build(:bulk_update_request) }

      should allow_value("test").for(:title)
      should_not allow_value("").for(:title)
      should_not allow_value(" ").for(:title)
      should_not allow_value("x" * 201).for(:title)

      should allow_value("test").for(:reason)
      should allow_value((["!post #1"] * 5).join("\n")).for(:reason)
      should_not allow_value("").for(:reason)
      should_not allow_value(" ").for(:reason)
      should_not allow_value("x" * 20_001).for(:reason)
      should_not allow_value((["!post #1"] * 10).join("\n")).for(:reason)

      should_not allow_value(0).for(:status)
      should_not allow_value("unknown").for(:status)

      should allow_value("nuke fumimi").for(:reason)
      should_not allow_value("").for(:script)
      should_not allow_value("x" * 20_001).for(:script)
    end

    context "when searching" do
      setup do
        @bur1 = create(:bulk_update_request, title: "foo", script: "create alias aaa -> bbb", user: @admin, approver: @admin, status: "approved")
        @bur2 = create(:bulk_update_request, title: "bar", script: "create implication bbb -> ccc", user: @admin)
      end

      should "work" do
        assert_search_equals(@bur1, user_name: @admin.name, approver_name: @admin.name, status: "approved")
      end

      context "by score" do
        setup do
          @user1 = create(:user)
          @user2 = create(:user)
          @user3 = create(:user)
          create(:forum_post_vote, forum_post: @bur1.forum_post, creator: @user1, score: 1)
          create(:forum_post_vote, forum_post: @bur1.forum_post, creator: @user2, score: 1)
          create(:forum_post_vote, forum_post: @bur2.forum_post, creator: @user3, score: -1)
        end

        should "filter by exact score" do
          assert_search_equals(@bur1, score: "2")
          assert_search_equals(@bur2, score: "-1")
        end

        should "filter by score greater than" do
          assert_search_equals(@bur1, score: ">0")
        end

        should "filter by score less than" do
          assert_search_equals(@bur2, score: "<0")
        end

        should "order by score descending" do
          assert_search_equals([@bur1, @bur2], order: "score_desc")
        end

        should "order by score ascending" do
          assert_search_equals([@bur2, @bur1], order: "score_asc")
        end

        should "search and order by score" do
          assert_search_equals([@bur2, @bur1], order: "score_asc", score: ">-20")
        end
      end
    end
  end
end
