require 'test_helper'

class BulkUpdateRequestTest < ActiveSupport::TestCase
  context "a bulk update request" do
    setup do
      @admin = FactoryBot.create(:admin_user)
      CurrentUser.user = @admin
      CurrentUser.ip_addr = "127.0.0.1"
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "#estimate_update_count" do
      setup do
        FactoryBot.create(:post, tag_string: "aaa")
        FactoryBot.create(:post, tag_string: "bbb")
        FactoryBot.create(:post, tag_string: "ccc")
        FactoryBot.create(:post, tag_string: "ddd")
        FactoryBot.create(:post, tag_string: "eee")

        @script = "create alias aaa -> 000\n" +
          "create implication bbb -> 111\n" +
          "remove alias ccc -> 222\n" +
          "remove implication ddd -> 333\n" +
          "mass update eee -> 444\n"
      end

      subject { BulkUpdateRequest.new(script: @script) }

      should "return the correct count" do
        assert_equal(3, subject.estimate_update_count)
      end
    end

    context "#update_notice" do
      setup do
        @mock_redis = MockRedis.new
        @forum_topic = FactoryBot.create(:forum_topic)
        TagChangeNoticeService.stubs(:redis_client).returns(@mock_redis)
      end

      should "update redis" do
        @script = "create alias aaa -> 000\n" +
          "create implication bbb -> 111\n" +
          "remove alias ccc -> 222\n" +
          "remove implication ddd -> 333\n" +
          "mass update eee -> 444\n"
        FactoryBot.create(:bulk_update_request, script: @script, forum_topic: @forum_topic)
        assert_equal(@forum_topic.id.to_s, @mock_redis.get("tcn:aaa"))
        assert_equal(@forum_topic.id.to_s, @mock_redis.get("tcn:000"))
        assert_equal(@forum_topic.id.to_s, @mock_redis.get("tcn:bbb"))
        assert_equal(@forum_topic.id.to_s, @mock_redis.get("tcn:111"))
        assert_equal(@forum_topic.id.to_s, @mock_redis.get("tcn:ccc"))
        assert_equal(@forum_topic.id.to_s, @mock_redis.get("tcn:222"))
        assert_equal(@forum_topic.id.to_s, @mock_redis.get("tcn:ddd"))
        assert_equal(@forum_topic.id.to_s, @mock_redis.get("tcn:333"))
        assert_equal(@forum_topic.id.to_s, @mock_redis.get("tcn:eee"))
        assert_equal(@forum_topic.id.to_s, @mock_redis.get("tcn:444"))
      end
    end

    context "on approval" do
      setup do
        @script = %q(
          create alias foo -> bar
          create implication bar -> baz
        )

        @bur = FactoryBot.create(:bulk_update_request, :script => @script)
        @bur.approve!(@admin)

        @ta = TagAlias.where(:antecedent_name => "foo", :consequent_name => "bar").first
        @ti = TagImplication.where(:antecedent_name => "bar", :consequent_name => "baz").first
      end

      should "reference the approver in the automated message" do
        assert_match(Regexp.compile(@admin.name), @bur.forum_post.body)
      end

      should "set the BUR approver" do
        assert_equal(@admin.id, @bur.approver.id)
      end

      should "create aliases/implications" do
        assert_equal("active", @ta.status)
        assert_equal("active", @ti.status)
      end

      should "set the alias/implication approvers" do
        assert_equal(@admin.id, @ta.approver.id)
        assert_equal(@admin.id, @ti.approver.id)
      end
    end

    should "create a forum topic" do
      assert_difference("ForumTopic.count", 1) do
        BulkUpdateRequest.create(:title => "abc", :reason => "zzz", :script => "create alias aaa -> bbb", :skip_secondary_validations => true)
      end
    end

    context "that has an invalid alias" do
      setup do
        @alias1 = FactoryBot.create(:tag_alias)
        @req = FactoryBot.build(:bulk_update_request, :script => "create alias bbb -> aaa")
      end

      should "not validate" do
        assert_difference("TagAlias.count", 0) do
          @req.save
        end
        assert_equal(["Error: A tag alias for aaa already exists (create alias bbb -> aaa)"], @req.errors.full_messages)
      end
    end

    context "for an implication that is redundant with an existing implication" do
      should "not validate" do
        FactoryBot.create(:tag_implication, :antecedent_name => "a", :consequent_name => "b")
        FactoryBot.create(:tag_implication, :antecedent_name => "b", :consequent_name => "c")
        bur = FactoryBot.build(:bulk_update_request, :script => "imply a -> c")
        bur.save

        assert_equal(["Error: a already implies c through another implication (create implication a -> c)"], bur.errors.full_messages)
      end
    end

    context "for an implication that is redundant with another implication in the same BUR" do
      setup do
        FactoryBot.create(:tag_implication, :antecedent_name => "b", :consequent_name => "c")
        @bur = FactoryBot.build(:bulk_update_request, :script => "imply a -> b\nimply a -> c")
        @bur.save
      end

      should "not process" do
        assert_no_difference("TagImplication.count") do
          @bur.approve!(@admin)
        end
      end

      should_eventually "not validate" do
        assert_equal(["Error: a already implies c through another implication (create implication a -> c)"], @bur.errors.full_messages)
      end
    end

    context "for a `category <tag> -> type` change" do
      should "work" do
        tag = Tag.find_or_create_by_name("tagme")
        bur = FactoryBot.create(:bulk_update_request, :script => "category tagme -> meta")
        bur.approve!(@admin)

        assert_equal(Tag.categories.meta, tag.reload.category)
      end
    end

    context "with an associated forum topic" do
      setup do
        @topic = FactoryBot.create(:forum_topic, :title => "[bulk] hoge")
        @post = FactoryBot.create(:forum_post, :topic_id => @topic.id)
        @req = FactoryBot.create(:bulk_update_request, :script => "create alias AAA -> BBB", :forum_topic_id => @topic.id, :forum_post_id => @post.id, :title => "[bulk] hoge")
      end

      should "gracefully handle validation errors during approval" do
        @req.stubs(:update).raises(AliasAndImplicationImporter::Error.new("blah"))
        assert_difference("ForumPost.count", 1) do
          @req.approve!(@admin)
        end

        assert_equal("pending", @req.reload.status)
        assert_match(/\[FAILED\]/, @topic.reload.title)
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

      should "downcase the text" do
        assert_equal("create alias aaa -> bbb", @req.script)
      end

      should "update the topic when processed" do
        assert_difference("ForumPost.count") do
          @req.approve!(@admin)
        end

        @topic.reload
        @post.reload
        assert_match(/\[APPROVED\]/, @topic.title)
      end

      should "update the topic when rejected" do
        @req.approver_id = @admin.id

        assert_difference("ForumPost.count") do
          @req.reject!(@admin)
        end

        @topic.reload
        @post.reload
        assert_match(/\[REJECTED\]/, @topic.title)
      end

      should "reference the rejector in the automated message" do
        @req.reject!(@admin)
        assert_match(Regexp.compile(@admin.name), @req.forum_post.body)
      end

      should "not send @mention dmails to the approver" do
        assert_no_difference("Dmail.count") do
          @req.approve!(@admin)
        end
      end
    end

    context "when searching" do
      setup do
        @bur1 = FactoryBot.create(:bulk_update_request, title: "foo", script: "create alias aaa -> bbb", user_id: @admin.id)
        @bur2 = FactoryBot.create(:bulk_update_request, title: "bar", script: "create implication bbb -> ccc", user_id: @admin.id)
        @bur1.approve!(@admin)
      end

      should "work" do
        assert_equal([@bur2.id, @bur1.id], BulkUpdateRequest.search.map(&:id))
        assert_equal([@bur1.id], BulkUpdateRequest.search(user_name: @admin.name, approver_name: @admin.name, status: "approved").map(&:id))
      end
    end
  end
end
