require 'test_helper'

class PostEventsControllerTest < ActionController::TestCase
  def setup
    super

    Timecop.travel(2.weeks.ago) do
      CurrentUser.user = FactoryGirl.create(:user)
      CurrentUser.ip_addr = "127.0.0.1"
    end

    @post = FactoryGirl.create(:post)
    @post_flag = PostFlag.create(:post => @post, :reason => "aaa", :is_resolved => false)
    @post_appeal = PostAppeal.create(:post => @post, :reason => "aaa")
  end

  def teardown
    super
    CurrentUser.user = nil
    CurrentUser.ip_addr = nil
  end

  context "GET /posts/:post_id/events" do
    should "render" do
      get :index, {:post_id => @post.id}, {:user_id => CurrentUser.user.id}
      assert_response :ok      
    end
  end
end
