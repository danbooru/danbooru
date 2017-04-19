require 'test_helper'

class BulkUpdateRequestTest < ActiveSupport::TestCase
  context "a bulk update request" do
    setup do
      @admin = FactoryGirl.create(:admin_user)
      CurrentUser.user = @admin
      CurrentUser.ip_addr = "127.0.0.1"
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "on approval" do
      setup do
        @script = %q(
          create alias foo -> bar
          create implication bar -> baz
        )

        @bur = FactoryGirl.create(:bulk_update_request, :script => @script)
        @bur.approve!(@admin)

        @ta = TagAlias.where(:antecedent_name => "foo", :consequent_name => "bar").first
        @ti = TagImplication.where(:antecedent_name => "bar", :consequent_name => "baz").first
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
        @alias1 = FactoryGirl.create(:tag_alias)
        @req = FactoryGirl.build(:bulk_update_request, :script => "create alias bbb -> aaa")
      end

      should "not validate" do
        assert_difference("TagAlias.count", 0) do
          @req.save
        end
        assert_equal(["Error: A tag alias for aaa already exists (create alias bbb -> aaa)"], @req.errors.full_messages)
      end
    end

    context "with an associated forum topic" do
      setup do
        @topic = FactoryGirl.create(:forum_topic, :title => "[bulk] hoge")
        @post = FactoryGirl.create(:forum_post, :topic_id => @topic.id)
        @req = FactoryGirl.create(:bulk_update_request, :script => "create alias AAA -> BBB", :forum_topic_id => @topic.id, :forum_post_id => @post.id, :title => "[bulk] hoge")
      end

      should "handle errors gracefully" do
        @req.stubs(:update).raises(RuntimeError.new("blah"))
        assert_difference("ForumPost.count", 1) do
          @req.approve!(@admin)
        end

        @topic.reload
        @post.reload
        assert_match(/\[FAILED\]/, @topic.title)
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
          @req.reject!
        end

        @topic.reload
        @post.reload
        assert_match(/\[REJECTED\]/, @topic.title)
      end
    end
  end
end
