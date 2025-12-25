require 'test_helper'

class PostAppealTest < ActiveSupport::TestCase
  context "In all cases" do
    setup do
      @user = create(:user, upload_points: 1000)
    end

    context "a user" do
      setup do
        @post = create(:post, tag_string: "aaa", is_deleted: true)
      end

      should "not be able to appeal a post more than once" do
        @post_appeal = create(:post_appeal, post: @post, creator: @user)
        @post_appeal = build(:post_appeal, post: @post, creator: @user)

        assert_equal(false, @post_appeal.valid?)
        assert_includes(@post_appeal.errors.full_messages, "You have already appealed this post")
      end

      should "not be able to appeal an active post" do
        @post.update!(is_deleted: false)
        @post_appeal = build(:post_appeal, post: @post, creator: @user)

        assert_equal(false, @post_appeal.valid?)
        assert_equal(["Post cannot be appealed"], @post_appeal.errors.full_messages)
      end

      context "appeal limits" do
        context "for members" do
          should "not be able to appeal more than their upload limit" do
            create(:post, uploader: @user, created_at: 1.day.ago)
            create_list(:post_appeal, 5, creator: @user)

            assert_equal(15, @user.upload_limit.upload_slots)
            assert_equal(15, @user.upload_limit.used_upload_slots)

            @post_appeal = build(:post_appeal, creator: @user)
            assert_equal(false, @post_appeal.valid?)
            assert_equal(["have reached your appeal limit"], @post_appeal.errors[:creator])
          end
        end

        context "for users with unrestricted uploads" do
          should "should not be able to appeal more than their limit" do
            @user = create(:contributor, upload_points: UploadLimit::MAXIMUM_POINTS)
            create(:post, uploader: @user, created_at: 1.day.ago)
            create_list(:post_appeal, 13, creator: @user)

            assert_equal(40, @user.upload_limit.upload_slots)
            assert_equal(39, @user.upload_limit.used_upload_slots)

            @post_appeal = build(:post_appeal, creator: @user)
            assert_equal(false, @post_appeal.valid?)
            assert_equal(["have reached your appeal limit"], @post_appeal.errors[:creator])
          end
        end
      end

      context "validation" do
        subject { build(:post_appeal) }

        should allow_value("").for(:reason)

        should_not allow_value(" ").for(:reason)
        should_not allow_value("\u200B").for(:reason)
      end
    end
  end
end
