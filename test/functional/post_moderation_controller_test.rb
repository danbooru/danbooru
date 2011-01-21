require File.join(File.dirname(__FILE__), %w(.. test_helper))

class PostModerationControllerTest < ActionController::TestCase
  context "A post moderation controller" do
    should "" do
      ModQueuePost.destroy_all

      p1 = create_post("hoge", :status => "pending")
      p2 = create_post("hoge", :status => "active")
      p3 = create_post("moge", :status => "active")

      p2.flag!("sage", User.find(1))
      p2.reload
      assert_not_nil(p2.flag_detail)

      get :moderate, {}, {:user_id => 1}
      assert_response :success

      get :moderate, {:query => "moge"}, {:user_id => 1}
      assert_response :success

      post :moderate, {:id => p1.id, :commit => "Approve"}, {:user_id => 1}
      p1.reload
      assert_equal("active", p1.status)

      post :moderate, {:id => p3.id, :reason => "sage", :commit => "Delete"}, {:user_id => 1}
      p3.reload
      assert_equal("deleted", p3.status)
      assert_not_nil(p3.flag_detail)
      assert_equal("sage", p3.flag_detail.reason)

      assert_equal(0, ModQueuePost.count)
      post :moderate, {:id => "3", :commit => "Hide"}, {:user_id => 1}
      assert_equal(1, ModQueuePost.count)
    end
  end
end
