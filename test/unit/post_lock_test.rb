require 'test_helper'

class PostLockTest < ActiveSupport::TestCase
  context "A post lock" do
    setup do
      @builder = create(:builder_user)
      @moderator = create(:moderator_user)
      @post = create(:post)
    end

    context "created by an builder" do
      should "be valid" do
        CurrentUser.scoped(@builder) do
          @lock = create(:post_lock, post: @post, creator: @builder, notes_lock: true)
        end
        assert(@lock.errors.empty?)
      end
    end

    should "initialize the expiration date" do
      CurrentUser.scoped(@builder) do
        @lock = create(:post_lock, post: @post, creator: @builder, rating_lock: true)
      end
      assert_not_nil(@lock.expires_at)
    end

    should "set the duration when specified" do
      CurrentUser.scoped(@builder) do
        @lock = create(:post_lock, post: @post, creator: @moderator, tags_lock: true, duration: 40)
      end
      assert(@lock.expires_at > 39.days.from_now)
    end

    should "record the lock changes" do
      CurrentUser.scoped(@builder) do
        @lock1 = create(:post_lock, post: @post, creator: @builder, tags_lock: true, rating_lock: true)
      end
      CurrentUser.scoped(@moderator) do
        @lock2 = create(:post_lock, post: @post, creator: @moderator, tags_lock: false)
      end
      assert_equal(true, @lock2.tags_lock_changed)
    end

    should "prevent edits when the edit level is changed" do
      CurrentUser.scoped(@moderator) do
        @lock = create(:post_lock, post: @post, creator: @moderator, comments_lock: true, edit_level: User::Levels::MODERATOR)
      end
      @lock_count = @post.locks.length
      assert_raises(User::PrivilegeError) do
        CurrentUser.scoped(@builder) do
          create(:post_lock, post: @post, creator: @builder, tags_lock: true)
        end
      end
      assert_equal(@lock_count, @post.locks.length)
    end
  end
end
