require 'test_helper'

class TagAliasRequestTest < ActiveSupport::TestCase
  context "A tag alias request" do
    setup do
      @user = FactoryBot.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    should "handle invalid attributes" do
      tar = TagAliasRequest.new(:antecedent_name => "", :consequent_name => "", :reason => "reason", :skip_secondary_validations => true)
      tar.create
      assert(tar.invalid?)
    end

    should "handle secondary validations" do
      tar = TagAliasRequest.new(:antecedent_name => "aaa", :consequent_name => "bbb", :reason => "reason", :skip_secondary_validations => false)
      tar.create
      assert(tar.invalid?)
    end

    should "create a tag alias" do
      assert_difference("TagAlias.count", 1) do
        tar = TagAliasRequest.new(:antecedent_name => "aaa", :consequent_name => "bbb", :reason => "reason", :skip_secondary_validations => true)
        tar.create
      end
      assert_equal("pending", TagAlias.last.status)
    end

    should "create a forum topic" do
      assert_difference("ForumTopic.count", 1) do
        tar = TagAliasRequest.new(:antecedent_name => "aaa", :consequent_name => "bbb", :reason => "reason", :skip_secondary_validations => true)
        tar.create
      end
    end

    should "create a forum post" do
      assert_difference("ForumPost.count", 1) do
        tar = TagAliasRequest.new(:antecedent_name => "aaa", :consequent_name => "bbb", :reason => "reason", :skip_secondary_validations => true)
        tar.create
      end
    end

    should "save the forum post id" do
      tar = TagAliasRequest.new(:antecedent_name => "aaa", :consequent_name => "bbb", :reason => "reason", :skip_secondary_validations => true)
      tar.create
      assert_equal(tar.forum_topic.posts.first.id, tar.tag_alias.forum_post.id)
    end
  end
end
