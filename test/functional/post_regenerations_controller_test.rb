require 'test_helper'

class PostRegenerationsControllerTest < ActionDispatch::IntegrationTest
  context "The post regenerations controller" do
    setup do
      @mod = create(:moderator_user, name: "yukari", created_at: 1.month.ago)
      @post = create(:post_with_file, filename: "test.jpg")
      perform_enqueued_jobs # add post to iqdb
    end

    context "create action" do
      should "render" do
        post_auth post_regenerations_path, @mod, params: { post_id: @post.id, category: "iqdb" }

        assert_redirected_to @post
        assert_enqueued_jobs(1, only: RegeneratePostJob)
      end

      should "not allow non-mods to regenerate posts" do
        post_auth post_regenerations_path, create(:user), params: { post_id: @post.id, category: "iqdb" }
        assert_response 403
      end

      context "for an IQDB regeneration" do
        should "regenerate IQDB" do
          post_auth post_regenerations_path, @mod, params: { post_id: @post.id, category: "iqdb" }
          perform_enqueued_jobs
        end

        should "log a mod action" do
          post_auth post_regenerations_path, @mod, params: { post_id: @post.id, category: "iqdb" }
          perform_enqueued_jobs

          assert_equal(@mod, ModAction.last.creator)
          assert_equal("post_regenerate_iqdb", ModAction.last.category)
          assert_equal("regenerated IQDB for post ##{@post.id}", ModAction.last.description)
          assert_equal(@post, ModAction.last.subject)
          assert_equal(@mod, ModAction.last.creator)
        end
      end

      context "for an image sample regeneration" do
        should "regenerate missing thumbnails" do
          @preview_file_size = @post.media_asset.variant(:preview).open_file.size
          @post.media_asset.variant(:preview).delete_file!
          assert_raise(Errno::ENOENT) { @post.file(:preview) }

          post_auth post_regenerations_path, @mod, params: { post_id: @post.id }
          perform_enqueued_jobs

          assert_equal(@preview_file_size, @post.file(:preview).size)
        end

        should "log a mod action" do
          post_auth post_regenerations_path, @mod, params: { post_id: @post.id }
          perform_enqueued_jobs

          assert_equal(@mod, ModAction.last.creator)
          assert_equal("post_regenerate", ModAction.last.category)
          assert_equal("regenerated image samples for post ##{@post.id}", ModAction.last.description)
          assert_equal(@post, ModAction.last.subject)
          assert_equal(@mod, ModAction.last.creator)
        end

        should "fix the width and height of exif-rotated images" do
          @post = create(:post_with_file, filename: "test-rotation-90cw.jpg")

          post_auth post_regenerations_path, @mod, params: { post_id: @post.id }
          perform_enqueued_jobs
          @post.reload

          assert_equal(96, @post.image_width)
          assert_equal(128, @post.image_height)
          assert_equal(96, @post.media_asset.image_width)
          assert_equal(128, @post.media_asset.image_height)
        end
      end
    end
  end
end
