require 'test_helper'

class UserRevertTest < ActiveSupport::TestCase
  context "Reverting a user's changes" do
    setup do
      @creator = create(:user)
      @user = create(:user)

      CurrentUser.scoped(@creator) do
        @parent = create(:post)
        @post = create(:post, :tag_string => "aaa bbb ccc", :rating => "q", :source => "xyz")
      end

      @post.stubs(:merge_version?).returns(false)
      CurrentUser.scoped(@user) do
        @post.update(:tag_string => "bbb ccc xxx", :source => "", :rating => "e")
      end
    end

    subject { UserRevert.new(@user.id) }

    should "have the correct data" do
      assert_equal("bbb ccc xxx", @post.tag_string)
      assert_equal("", @post.source)
      assert_equal("e", @post.rating)
    end

    context "when processed" do
      setup do
        CurrentUser.as(@user) do
          subject.process
        end
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
