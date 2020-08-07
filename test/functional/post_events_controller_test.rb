require 'test_helper'

class PostEventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    travel_to(2.weeks.ago) do
      @user = create(:user)
      @mod = create(:mod_user)
    end

    as(@user) do
      @post = create(:post, is_flagged: true)
      create(:post_flag, post: @post, status: :rejected)
      @post.update(is_deleted: true)
      create(:post_appeal, post: @post, status: :succeeded)
      @post.approve!(@mod)
    end
  end

  context "get /posts/:post_id/events" do
    should "render" do
      get_auth post_events_path(post_id: @post.id), @user
      assert_response :ok
    end

    should "render for mods" do
      get_auth post_events_path(post_id: @post.id), @mod
      assert_response :success
    end
  end

  context "get /posts/:post_id/events.xml" do
    setup do
      get_auth post_events_path(post_id: @post.id), @user, params: {:format => "xml"}
      @xml = Hash.from_xml(response.body)
      @appeal = @xml["post_events"].find { |e| e["type"] == "a" }
    end

    should "render" do
      assert_not_nil(@appeal)
    end
  end
end
