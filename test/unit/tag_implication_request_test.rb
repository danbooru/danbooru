require 'test_helper'

class TagImplicationRequestTest < ActiveSupport::TestCase
  context "A tag implication request" do
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
      tir = TagImplicationRequest.new(:antecedent_name => "", :consequent_name => "", :reason => "reason", :skip_secondary_validations => true)
      tir.create
      assert(tir.invalid?)
    end

    should "handle secondary validations" do
      tir = TagImplicationRequest.new(:antecedent_name => "aaa", :consequent_name => "bbb", :reason => "reason", :skip_secondary_validations => false)
      tir.create
      assert(tir.invalid?)
    end

    should "create a tag implication" do
      assert_difference("TagImplication.count", 1) do
        tir = TagImplicationRequest.new(:antecedent_name => "aaa", :consequent_name => "bbb", :reason => "reason", :skip_secondary_validations => true)
        tir.create
      end
      assert_equal("pending", TagImplication.last.status)
    end

    should "create a forum topic" do
      assert_difference("ForumTopic.count", 1) do
        tir = TagImplicationRequest.new(:antecedent_name => "aaa", :consequent_name => "bbb", :reason => "reason", :skip_secondary_validations => true)
        tir.create
      end
    end

    should "create a forum post" do
      assert_difference("ForumPost.count", 1) do
        tir = TagImplicationRequest.new(:antecedent_name => "aaa", :consequent_name => "bbb", :reason => "reason", :skip_secondary_validations => true)
        tir.create
      end
    end
  end
end
