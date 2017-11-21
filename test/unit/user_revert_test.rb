require 'test_helper'

class UserRevertTest < ActiveSupport::TestCase
  context "Reverting a user's changes" do
    setup do
      User.any_instance.stubs(:validate_sock_puppets).returns(true)
      
      @creator = FactoryGirl.create(:user)
      @user = FactoryGirl.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"

      CurrentUser.scoped(@creator) do
        @parent = FactoryGirl.create(:post)
        @post = FactoryGirl.create(:post, :tag_string => "aaa bbb ccc", :rating => "q", :source => "xyz")
      end

      @post.stubs(:merge_version?).returns(false)
      @post.update_attributes(:tag_string => "bbb ccc xxx", :source => "", :rating => "e")
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    subject { UserRevert.new(@user.id) }

    should "have the correct data" do
      assert_equal("bbb ccc xxx", @post.tag_string)
      assert_equal("", @post.source)
      assert_equal("e", @post.rating)
    end

    context "when processed" do
      setup do
        subject.process
        @post.reload
      end

      should "revert the user's changes" do
        assert_equal("aaa bbb ccc", @post.tag_string)
        assert_equal("xyz", @post.source)
        assert_equal("q", @post.rating)
      end
    end

  end
end
