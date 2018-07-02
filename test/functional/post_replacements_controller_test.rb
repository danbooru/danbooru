require 'test_helper'

class PostReplacementsControllerTest < ActionDispatch::IntegrationTest
  context "The post replacements controller" do
    setup do
      Delayed::Worker.delay_jobs = true # don't delete the old images right away

      @user = create(:moderator_user, can_approve_posts: true, created_at: 1.month.ago)
      @user.as_current do
        @post = create(:post, source: "https://google.com")
        @post_replacement = create(:post_replacement, post: @post)
      end
    end

    teardown do
      Delayed::Worker.delay_jobs = false
    end

    context "create action" do
      should "render" do
        params = {
          format: :json,
          post_id: @post.id,
          post_replacement: {
            replacement_url: "https://raikou1.donmai.us/d3/4e/d34e4cf0a437a5d65f8e82b7bcd02606.jpg",
          }
        }

        assert_difference(-> { @post.replacements.size }) do
          post_auth post_replacements_path, @user, params: params
          @post.reload
        end

        travel_to(Time.now + PostReplacement::DELETION_GRACE_PERIOD + 1.day) do
          Delayed::Worker.new.work_off
        end

        assert_response :success
        assert_equal("https://raikou1.donmai.us/d3/4e/d34e4cf0a437a5d65f8e82b7bcd02606.jpg", @post.source)
        assert_equal("d34e4cf0a437a5d65f8e82b7bcd02606", @post.md5)
        assert_equal("d34e4cf0a437a5d65f8e82b7bcd02606", Digest::MD5.file(@post.file(:original)).hexdigest)
      end
    end

    context "update action" do
      should "update the replacement" do
        params = {
          format: :json,
          id: @post_replacement.id,
          post_replacement: {
            file_size_was: 23,
            file_size: 42,
          }
        }

        put_auth post_replacement_path(@post_replacement), @user, params: params
        @post_replacement.reload
        assert_equal(23, @post_replacement.file_size_was)
        assert_equal(42, @post_replacement.file_size)
      end
    end

    context "index action" do
      should "render" do
        get post_replacements_path, params: {format: "json"}
        assert_response :success
      end
    end
  end
end
