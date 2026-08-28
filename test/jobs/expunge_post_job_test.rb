require "test_helper"

class ExpungePostJobTest < ActiveJob::TestCase
  context "ExpungePostJob" do
    setup do
      @user = create(:admin_user)
      @post = create(:post_with_file, tag_string: "1girl", filename: "jpg/test.jpg")
    end

    should "expunge the post" do
      ExpungePostJob.perform_now(post: @post, user: @user)

      assert_equal(false, Post.exists?(@post.id))
      assert_equal("post_permanent_delete", ModAction.last.category)
      assert_equal(@user, ModAction.last.creator)
    end

    should "run before uploads are processed" do
      assert_operator(ExpungePostJob.new.priority, :<, ProcessUploadJob.new.priority)
    end

    should "retry until the post is expunged if an attempt fails partway through" do
      # Fail after the files have already been moved to the trash.
      CloudflareService.any_instance.stubs(:purge_cache).raises(Net::ReadTimeout).then.raises(Net::ReadTimeout).then.returns(nil)

      perform_enqueued_jobs do
        ExpungePostJob.perform_later(post: @post, user: @user)
      end

      assert_equal(false, Post.exists?(@post.id))
      assert_equal(0, Tag.find_by_name("1girl").post_count)
      assert_raise(StandardError) { @post.file(:original) }
      assert_raise(StandardError) { @post.file(:"180x180") }
    end

    should "expunge the post if some files were already moved to the trash" do
      @post.media_asset.variant(:original).trash_file!

      ExpungePostJob.perform_now(post: @post, user: @user)

      assert_equal(false, Post.exists?(@post.id))
      assert_raise(StandardError) { @post.file(:"180x180") }
    end

    should "move the files before updating the tag counts so tags aren't locked during file transfers" do
      order = sequence("expunge")
      MediaAsset.any_instance.expects(:trash!).in_sequence(order)
      Tag.expects(:decrement_post_counts).in_sequence(order)

      ExpungePostJob.perform_now(post: @post, user: @user)
    end

    should "not expunge the same post twice if it was already expunged by another job" do
      stale_post = Post.find(@post.id)
      ExpungePostJob.perform_now(post: @post, user: @user)

      assert_no_difference(["ModAction.count", "Tag.find_by_name('1girl').post_count"]) do
        assert_nothing_raised { ExpungePostJob.perform_now(post: stale_post, user: @user) }
      end
    end
  end
end
