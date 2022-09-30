require 'test_helper'

class ModqueueControllerTest < ActionDispatch::IntegrationTest
  context "The modqueue controller" do
    setup do
      @admin = create(:admin_user)
      @user = create(:user)
    end

    context "index action" do
      should "render" do
        create(:post, is_pending: true)
        get_auth modqueue_index_path, @admin

        assert_response :success
      end

      should "render for a json response" do
        create(:post, is_pending: true)
        get_auth modqueue_index_path, @admin, as: :json

        assert_response :success
      end

      should "support the only= URL param" do
        @post = create(:post, is_pending: true)
        get_auth modqueue_index_path(only: "rating"), @admin, as: :json

        assert_response :success
        assert_equal([{ "rating" => @post.rating }], response.parsed_body)
      end

      should "order posts correctly when searching for tags" do
        post1 = create(:post, tag_string: "touhou", is_pending: true, score: 5)
        post2 = create(:post, tag_string: "touhou", is_pending: true, score: 10)
        post3 = create(:post, tag_string: "touhou", is_pending: true, score: 15)

        get_auth modqueue_index_path(search: { tags: "touhou", order: "score_asc" }), @admin, as: :json

        assert_response :success
        assert_equal([post1.id, post2.id, post3.id], response.parsed_body.pluck("id"))
      end

      should "filter negated tags correctly" do
        post1 = create(:post, tag_string: "touhou", is_pending: false)
        post2 = create(:post, tag_string: "touhou", is_pending: true)

        get_auth modqueue_index_path(search: { tags: "-solo" }), @admin, as: :json
        assert_response :success
        assert_equal([post2.id], response.parsed_body.pluck("id"))

        get_auth modqueue_index_path(search: { tags: "touhou -solo" }), @admin, as: :json
        assert_response :success
        assert_equal([post2.id], response.parsed_body.pluck("id"))

        get_auth modqueue_index_path(search: { tags: "-touhou" }), @admin, as: :json
        assert_response :success
        assert_equal([], response.parsed_body.pluck("id"))
      end

      should "filter the disapproved:<reason> metatag correctly" do
        post1 = create(:post, is_pending: true)
        post2 = create(:post, is_deleted: true)
        create(:post_disapproval, post: post2, reason: "poor_quality")

        get_auth modqueue_index_path(search: { tags: "disapproved:poor_quality" }), @admin, as: :json
        assert_response :success
        assert_equal([], response.parsed_body.pluck("id"))
      end

      should "include appealed posts in the modqueue" do
        @appeal = create(:post_appeal)
        get_auth modqueue_index_path, @admin

        assert_response :success
        assert_select "#post-#{@appeal.post_id}"
      end
    end
  end
end
