require 'test_helper'

class PostEventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    travel_to(2.weeks.ago) do
      @user = create(:user)
      @mod = create(:mod_user)
    end

    as_user do
      @post = create(:post)
      @post.flag!("aaa")
      create(:post_appeal, post: @post)
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

    should "return is_resolved correctly" do
      assert_equal(false, @appeal["is_resolved"])
    end
  end
end
